#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import argparse
import re
import os
import sqlite3
import hashlib


class Database(object):
    class NotFoundError(Exception):
        pass

    def __init__(self, databasefile):
        self.conn = sqlite3.connect(databasefile)
        self.conn.text_factory = bytes
        self.db = self.conn.cursor()

    def __enter__(self):
        self.create_table()
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self.conn.commit()

    def commit(self):
        self.conn.commit()

    def create_table(self):
        self.db.execute('''CREATE TABLE IF NOT EXISTS filehashes
             (filename text PRIMARY KEY, hash text NOT NULL)''')
        self.db.execute('''CREATE INDEX IF NOT EXISTS hashes ON
             filehashes(hash)''')

    def store(self, filename, checksum):
        try:
            self.db.execute('INSERT INTO filehashes VALUES (?,?)', (filename, checksum))
        except sqlite3.IntegrityError:
            self.db.execute('UPDATE filehashes SET  hash=? WHERE filename=?', (checksum, filename))

    def get_checksum(self, filename):
        try:
            self.db.execute('SELECT hash from filehashes where filename=?', (filename,))
        except UnicodeEncodeError:
            print("Could not encode '{}'".format(filename.encode('utf8', 'replace')))
            raise
        try:
            return self.db.fetchone()[0]
        except TypeError:
            raise self.NotFoundError

    def get_files(self, checksum):
        self.db.execute('SELECT filename from filehashes where hash=?', (checksum,))
        return [row[0] for row in self.db.fetchall()]

    def get_all_files(self):
        self.db.execute('SELECT filename from filehashes')
        return set([row[0] for row in self.db.fetchall()])

    def get_all_duplicates(self):
        self.db.execute('SELECT hash, group_concat(filename, "|||") FROM filehashes GROUP BY hash HAVING COUNT(hash) >1')
        duplicates = []
        # for row in self.db.fetchall():
        #     string = row[1].decode('utf8', 'replace')
        #     duplicates.append("\n".join(string.split("|||")))
        # return duplicates
        return ["\n".join(row[1].decode('utf8', 'replace').split("|||")) for row in self.db.fetchall()]

    def is_duplicate(self, filename, checksum):
        files = self.get_files(checksum)
        try:
            files.remove(filename)
        except ValueError:
            pass
        if len(files) > 0:
            return True
        else:
            return False

    def is_file_in_db(self, filename):
        try:
            self.get_checksum(filename)
        except self.NotFoundError:
            return False
        return True

    def remove(self, filename):
        self.db.execute('DELETE FROM filehashes WHERE filename=?', (filename,))


class DuplicateFinder(object):
    class CouldNotHash(Exception):
        pass

    def __init__(self, database, verbose, silent):
        self.database = database
        self.verbose = verbose
        self.silent = silent
        self.filelist = set()

    def debug(self, message):
        if self.verbose:
            print(message)

    def generate_hash(self, filename):
        BUF_SIZE = 65536
        sha1 = hashlib.sha1()
        try:
            with open(filename, 'rb') as filestream:
                while True:
                    data = filestream.read(BUF_SIZE)
                    if not data:
                        break
                    sha1.update(data)
            return sha1.hexdigest()
        except IOError as e:
            raise self.CouldNotHash("Could not hash '{0}': {1}".format(filename, e))

    def is_excluded(self, string, exclude):
        for exclusion in exclude:
            try:
                if re.match(exclusion, string):
                    self.debug("Excluding '{0}' due to matching regex '{1}'".format(string, exclusion))
                    return True
            except Exception as e:
                raise Exception("Could not parse Regex: '{0}': {1}".format(exclusion, e))
        return False

    def generate_filelist(self, directory, exclude=[]):
        self.debug(self.header("Getting Files:"))
        filelist = []
        for root, dirs, files in os.walk(directory):
            if self.is_excluded(root, exclude):
                del dirs[:]
                continue
            for name in files:
                if self.is_excluded(name, exclude):
                    continue
                filelist.append(os.path.join(root, name))
        self.filelist = set(filelist)

    def update_db(self, recreate_hash):
        self.debug(self.header("Updating DB:"))
        number_or_files = len(self.filelist)
        if not self.silent:
            print("Processing {0} files".format(number_or_files))
        count = 0
        if not self.verbose and not self.silent:
            print("      0 ", end='')
        for name in self.filelist:
            count += 1
            self.debug("checking '{0}'".format(name))
            if (recreate_hash or
               not self.database.is_file_in_db(name)):
                if not self.verbose and not self.silent:
                    print(".", end='', flush=True)
                    if count % 200 == 0:
                        print("\n{:>7} ".format(count), end='')
                try:
                    checksum = self.generate_hash(name)
                    self.debug("Storing Hash for file '{0}'".format(name))
                    self.database.store(name, checksum)
                except self.CouldNotHash as e:
                    print(e)
                except UnicodeEncodeError as e:
                    print("Could not handle file '{0}': {1}".format(name, e))
            else:
                self.debug("File in DB: '{0}'".format(name))
                if not self.verbose and not self.silent:
                    print("*", end='', flush=True)
                    if count % 200 == 0:
                        print("\n{:>7} ".format(count), end='')
            if count % 10000 == 0:
                self.debug("Committing changes to database")
                self.database.commit()
        if not self.verbose and not self.silent:
            print()

    def cleanup_db(self):
        self.debug(self.header("Cleanup Database:"))
        files_in_db = self.database.get_all_files()
        removed_files = files_in_db - self.filelist
        for name in removed_files:
            self.debug("Removing file '{0}'".format(name))
            self.database.remove(name)

    def print_duplicates(self, filename, checksum):
        duplicates = self.database.get_files(checksum)
        try:
            duplicates.remove(filename)
        except ValueError:
            pass
        if len(duplicates):
            print("Found Duplicates for file '{0}': {1}".format(filename, str(duplicates)))

    def print_all_duplicates(self):
        self.debug(self.header("Finding Duplicates:"))
        sep = "\n" + "-" * 80 + "\n"
        all_duplicates = self.database.get_all_duplicates()
        if len(all_duplicates):
            print(sep.join(all_duplicates))
        else:
            print("No Duplicates found!")

    def header(self, message):
        length = len(message)
        border = "-" * (length + 4)
        return "{0}\n| {1} |\n{0}".format(border, message)


def u(s):
    return unicode(s, "utf-8")


def b(s):
    return s.encode('utf8', 'replace')


def parse_args():
    parser = argparse.ArgumentParser(description='Find Duplicates in Directory')
    parent_parser = argparse.ArgumentParser(add_help=False)
    verbosity_parser = parent_parser.add_mutually_exclusive_group()
    verbosity_parser.add_argument("-v", "--verbose", help="Print what is happening", action='store_true')
    verbosity_parser.add_argument("-s", "--silent", help="Output only errors", action='store_true')
    parent_parser.add_argument("-f", "--file", help="Store SHA1 in this file", required=True, metavar="SHA1-FILE", type=u)
    subparsers = parser.add_subparsers(dest='action')
    duplicates_parser = subparsers.add_parser('duplicates', help="Get all duplicates", parents=[parent_parser])
    cleanup_parser = subparsers.add_parser('cleanup', help="remove missing files from database", parents=[parent_parser])
    cleanup_parser.add_argument('directory', type=u, help="Root directory to find all files.")
    check_parser = subparsers.add_parser('check', help="Check the file for duplicates in the SHA1 Store", parents=[parent_parser])
    check_parser.add_argument('target')
    update_parser = subparsers.add_parser('update', help="Update the SHA1 file with date from the Directory", parents=[parent_parser])
    update_parser.add_argument('directory', type=b)
    update_parser.add_argument("-r", "--recreate", help="Recreate hashes", action='store_true')
    update_parser.add_argument("-d", "--printduplicates", help="Print duplicates when updating", action='store_true')
    update_parser.add_argument("-c", "--cleanup", help="remove missing files from database", action='store_true')
    update_parser.add_argument("-e", "--exclude", help="Exclude this file/paths with this regex", action='append', default=[], type=b)

    return parser.parse_args()


def main():
    args = parse_args()
    with Database(args.file) as database:
        finder = DuplicateFinder(database, args.verbose, args.silent)

        if args.action == "update":
            finder.generate_filelist(args.directory, args.exclude)
            finder.update_db(args.recreate)
            if args.cleanup:
                finder.cleanup_db()
            if args.printduplicates:
                finder.print_all_duplicates()

        if args.action == "check":
            checksum = finder.generate_hash(args.target)
            finder.print_duplicates(args.target, checksum)

        if args.action == "duplicates":
            finder.print_all_duplicates()

        if args.action == "cleanup":
            finder.generate_filelist(args.directory, args.exclude)
            finder.cleanup_db()
            finder.generate_filelist(args.directory, args.exclude)


# Python 3 Helper
# there is no unicode funtion in py3

try:
    unicode
except NameError:
    # Define `unicode` for Python3
    def unicode(s, *_):
        return s
# END py3-Helper

if __name__ == '__main__':
    main()
