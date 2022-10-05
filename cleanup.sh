#!/usr/bin/env zsh

# remove temporary files 
if [[ -f *.bak ]]
then
	rm *.bak
fi

for f in *.txt
do
	cat $f | aspell list >> words.list.tmp
done

if [[ -s words.list.tmp ]]
then
	awk '{ print "\\b" $1 "\\b" }' words.list.tmp > words.list
	$(ggrep -nf words.list *.txt) > errors
	rm words.list
fi
rm words.list.tmp

if [[ -s errors ]]
then
	nvim -q errors
fi

if [[ -s errors ]]
then
	rm errors
fi

# final check
for f in *.txt
do
	cat $f >> check
	echo >> check
done

less check
rm check

ls *.txt | pbcopy
echo "Filenames copied to clipboard."

PWD=$(pwd)
if [[ -d "${PWD}.bak" ]]
then
	rm -rf "${PWD}.bak"
	echo "Backup removed."
fi

mv $PWD $(dirname $(dirname $PWD))
echo "${PWD} moved."
cd ..
