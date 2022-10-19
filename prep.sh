#! /usr/bin/env zsh

FILE=$(realpath $1) # full path to file name. must be pdf
START=$2 # starting page of pdf file
if [[ -n $3 ]]
then
	FINISH=$3 # ending page of pdf file
fi

# pull metadata into csv and write summaries out to text files
# named following this schema: {congress}_{session}_{bill type}_{bill number}.txt
if [[ -n $FINISH ]]
then
	python3 get_summaries.py $FILE $START $FINISH
else
	python3 get_summaries.py $FILE $START
fi

# get file's name for name of new directory and iteration purposes
FILE_BASENAME=$(basename $FILE .pdf) 

# make new directory and move generated files into it
if [[ -n $FINISH ]]
then
	NEW_DIR="${FILE_BASENAME}_${START}_${FINISH}"
else
	NEW_DIR="${FILE_BASENAME}_${START}"
fi

for f in *.{txt,csv}
do
	gsed -f common_errors.sed -i $f
done

for f in *.txt
do
	gsed -i.bak -Ez -f clean_lines.sed $f
done

mkdir $NEW_DIR
mv $FILE_BASENAME*.??? $NEW_DIR
cp -R $NEW_DIR "${NEW_DIR}.bak"
