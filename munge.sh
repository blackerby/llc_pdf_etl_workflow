#!/usr/bin/env zsh

# should operate on renamed files
for f in *.txt
do
	tr -d '\n' <$f >"tmp_${f}" && mv "tmp_${f}" $f # drop the newlines
	gsed -i 's/@/\n/g' $f # replace the marker from above with a newline
	gsed -i 's/- //g' $f # fix breaks in words
done

