#!/usr/bin/env zsh

for f in *.txt
do
	gsed -i.bak -Ez -f ../clean_lines.sed $f
	# interactive part:
	aspell check $f
	nvim $f
done
