#!/usr/bin/env zsh

# remove temporary files 
ls | ggrep -P "^\d{2}_\d_\w\d{1,5}\.txt(\.bak)?$" | xargs rm

# final check
for f in *.txt
do
	nvim $f
done

