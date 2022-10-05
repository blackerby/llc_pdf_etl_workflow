#!/usr/bin/env zsh

# remove backup directory
PWD=$(pwd)
rm -rf "${PWD}.bak"

# create new backup directory
cp -R $PWD "${PWD}.bak"

# should operate on renamed files
for f in *.txt
do
	tr -d '\n' <$f >"tmp_${f}" && mv "tmp_${f}" $f # drop the newlines
	gsed -i 's/@/\n/g' $f # replace the marker from above with a newline
	echo >> $f
done

