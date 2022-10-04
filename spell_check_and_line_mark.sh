#!/usr/bin/env zsh

for f in *.txt
do
	gsed -i.bak -z -f ../mark_lines.sed $f
	# interactive part:
	aspell check $f
	# insert '@' to mark newlines to keep
	# rename file according to latest action
	# command in vim for above: :saveas %:r_YYYYMMDD_%:e
	nvim $f
	rm $f
done
