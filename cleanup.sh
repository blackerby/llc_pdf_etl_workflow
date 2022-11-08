#!/usr/bin/env zsh

# remove temporary files 
rm -f *.bak
rm -f *~

# tsv file for easier command line text processing
filepath=`realpath *.csv`
dirname=`dirname $filepath`
basename=`basename $filepath '.csv'`
mlr --c2t cut -o -f bill_type,bill_number,sponsor,action_date,committee $filepath > "$dirname/$basename.tsv"
echo "Created $dirname/$basename.tsv"

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
