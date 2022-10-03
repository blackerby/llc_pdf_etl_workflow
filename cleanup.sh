#!/usr/bin/env zsh

# remove temporary files 
ls | ggrep -P "^\d{2}_\d_\w\d{1,5}\.txt(\.bak)?$" | xargs rm

touch words

for f in *.txt
do
	echo $f >> words.txt
	cat $f | aspell list >> words
done

less words
rm words

# final check
for f in *.txt
do
	nvim $f
done

ls *.txt | pbcopy
echo "Filenames copied to clipboard."

PWD=$(pwd)
rm -rf "${PWD}.bak"
echo "Backup removed."
mv $PWD dirname $(dirname $PWD))
echo "${PWD} moved."
