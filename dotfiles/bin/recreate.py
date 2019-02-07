#!/usr/bin/env python

import requests
import logging
import argparse
from getpass import getpass


class ICCClient(object):
    def __init__(self, args, logger=None):
        self.api = args['api']
        self.user = args['user']
        self.password = args['password']
        logging.basicConfig(level=args['loglevel'])
        self.logger = logger or logging.getLogger(__name__)

    def get_schema(self, action, params={}):
        params['action'] = action
        url = "%s/schema" % self.api
        self.logger.debug("Getting schema for action '%s': '%s'" % (action, url))
        request = requests.get(url, params=params, auth=(self.user, self.password))
        return request.json()


def parse_arguments(argv=None):
    description = """
    Recreate a VM
    """
    parser = argparse.ArgumentParser(description=description)
    # server, project, repo, target, symlinks={}
    parser.add_argument('-u', '--user', help="Username", required=True)
    parser.add_argument('-s', '--server', help="FQDN of the Server to be recreated", required=True)
    parser.add_argument('-a', '--api', help="URL for the ICC API", default="https://icc.eu.idealo.com/api/v1/workflow/")
    parser.add_argument(
        '-d',
        '--debug',
        action='store_const',
        const=logging.INFO,
        default=logging.WARNING,
        dest='loglevel'
    )
    parser.add_argument('--password', help="Password")
    args = parser.parse_args(argv)
    if not args.password:
        args.password = getpass()
    return args

def main():
    args = vars(parse_arguments())
    client = ICCClient(args)
    print client.get_schema('recreate')


if __name__ == "__main__":
    main()
