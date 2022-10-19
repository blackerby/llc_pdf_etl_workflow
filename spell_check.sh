#!/usr/bin/env zsh

for f in *.txt
do
	# interactive part:
	aspell check $f
done
