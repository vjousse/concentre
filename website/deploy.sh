#!/usr/bin/env bash
#
# Run it once the GitHub release is published, so that download links work.
set -euo pipefail
cd "$(dirname "$0")"

# Replace with your SSH destination and the directory served by your web server.
DEST="vjousse@petrichor.jousse.org:/home/data/concentre.org/"

zola build
rsync -avz --delete public/ "$DEST"
