# Semi-automated workflow for CRS Bill Digest Summaries

This repository contains scripts I'm using to speed up the workflow for my Fall 2022 Law Library of Congress Remoted Metadata Internship. Much of the work is done by the python script, and the shell scripts are used to automate usage of some command-line text-processing utilities. The scripts rely heavily on `aspell`, `nvim`, and `sed`. There's even a line of `awk` in there. [Miller](https://github.com/johnkerl/miller) is a recently added dependency.

## Installing the python script.

You can be productive with just the python script in this repository. To work with that script, make sure you have a working version of Python 3 on your machine. Easy to follow download and installation instructions are available [here](https://www.python.org/downloads/).

Next, if you're working on a Unix-like system such as MacOS or Linux, open up a terminal window and run
```bash
$ python3 -m venv venv
```
(The `$` represents your command prompt.) This will create a python virtual environment for you to install the packages necessary for the script to work and it will save your python version info. Activate your virtual environment by running `source venv/bin/activate` at your command prompt.

I'm not familiar with how to run this script on Windows, but I hear good things about the [Windows Subsystem for Linux](https://learn.microsoft.com/en-us/windows/wsl/install) for emulating a Linux/Unix style environment on Windows.

Once your virtual environment is set up, you need to install two libraries. First, run `pip install more_itertools` at your command prompt, then run `pip install PyPDF2`. Everything should be ready to go now.

At a command prompt, run `$ python get_summaries.py {FILENAME} {STARTPAGE} {OPTIONALENDPAGE}`. If everything installed correctly, you should have a CSV file and several text files in your directory.

## The scripts

The workflow generally follows this order:
```bash
./prep.sh path_to_pdf start_page end_page (optional)
cd directory_created_by_prep
../spell_check_and_line_mark.sh
../cleanup.sh
```

### `prep.sh`
`prep.sh` takes a path to a PDF file, a start page number, and an optional end page number and produces two directories that follow this naming schema: `Congress_Session_StartPageNumber(_OptionalEndPageNumber)` and `Congress_Session_StartPageNumber(_OptionalEndPageNumber).bak` (a backup of the other directory in case you make a mistake while editing). Inside each directory are
- a CSV containing metadata extracted from the first line of each bill summary; other bill actions require manual input into the spreadsheet.
- several text files containing the summaries extracted from the specified pages of the PDF.

### `spell_check_and_line_mark.sh`
`spell_check_and_line_mark.sh` needs a new name, but it currently runs a `sed` script that replaces some Unicode characters like double quotes and emdashes with ASCII equivalents and eliminates some weird stray OCR artifacts. It then puts the user into `aspell` to do some spell-checking, and finally opens `nvim` to allow for manual editing. This is when I enter bill action metadata besides the "Introduced" action into the spreadsheet.

### `cleanup.sh`
`cleanup.sh` does some final spell-checking, opens the text files for a final once over, and copies the names of the text files to the clipboard for pasting into a spreadsheet. It also removes backup files and directories and extracts the columns that actually have data in them from the CSV metadata file into a TSV file for easier analysis using command line text processing tools.

to be continued...
