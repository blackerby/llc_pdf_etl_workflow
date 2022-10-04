#!/usr/bin/env zsh

# remove temporary files 
ls | ggrep -P "^\d{2}_\d_\w\d{1,5}\.txt(\.bak)?$" | xargs rm

touch words.list.tmp

for f in *.txt
do
	cat $f | aspell list >> words.list.tmp
done

if [[ -n words.list.tmp ]]
then
	awk '{ print "\\b" $1 "\\b" }' words.list.tmp > words.list
	errors=$(ggrep -nf words.list *.txt)
	rm words.list
fi
rm words.list.tmp

if [[ -n errors ]]
then
	nvim -q errors
fi

# final check
for f in *.txt
do
	cat $f
	echo '\n'
done | less

ls *.txt | pbcopy
echo "Filenames copied to clipboard."

PWD=$(pwd)
rm -rf "${PWD}.bak"
echo "Backup removed."
mv $PWD $(dirname $(dirname $PWD))
echo "${PWD} moved."
cd ..
