#!/usr/bin/env bash

# Add to crontab with the following schedule:
# * */8 * * * /usr/local/bin/clean-tmp.sh

# Find all non-root owned files in /tmp that haven't been accessed in >2 days
find /tmp -type f \( ! -user root \) -atime +2 -delete
