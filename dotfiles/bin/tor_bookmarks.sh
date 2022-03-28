#!/bin/bash

SOURCE="$HOME/.mozilla/firefox/0qb74bwx.Tor/places.sqlite"
TARGET="/media/veracrypt1/bookmarks.html"

cat <<EOF >$TARGET
<html>
<head>
<title>Bookmarks</title>
</head>
<body>
<ul>
EOF

echo "select url, moz_bookmarks.title from moz_bookmarks, moz_places where
moz_places.id=moz_bookmarks.fk;" | \
    sqlite3 $SOURCE | \
    sed 's/^/<li><a href="/; s/|/">/; s#$#</a></li>#' >>$TARGET

cat <<EOF >>$TARGET
</ul>
</body>
</html>
EOF
