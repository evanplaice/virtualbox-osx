#!/bin/sh

# store the input <arg> as '<arg>.img'
TEMP="$1.$$.img"
# delete <arg>.img if it already exists
trap "rm -f $TEMP 2>/dev/null" 1 2 3 11 15
# calculate the <arg>.vdi header offset block
offset=`hexdump -s 0x158 -n 4 "$1" | head -1 | awk '{print $5 $4 $3 $2}'`
# calculate the <arg>.vdi header offset
offset512=`echo "obase=16; ibase=16; $offset / 200" | bc`
# create a fake <arg>.img link pointing to <arg>.vdi
ln "$1" "$TEMP"
echo hdid -section "0x$offset512" \"$TEMP\"
# mount the <arg>.img
hdid -section "0x$offset512" -nomount "$TEMP"
# delete the fake <arg>.img
rm -f "$TEMP"