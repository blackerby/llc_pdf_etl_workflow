# Semi-automated workflow for CRS Bill Digest Summaries

This repository contains scripts I'm using to speed up the workflow for my Fall 2022 Law Library of Congress Remoted Metadata Internship. Much of the work is done by the python script, and the shell scripts are used to automate usage of some command-line text-processing utilities. The scripts rely heavily on `aspell`, `nvim`, and `sed`. There's even a line of `awk` in there.

The workflow generally follows this order:
```bash
./prep.sh path_to_pdf start_page end_page (optional)
cd directory_created_by_prep
../spell_check_and_line_mark.sh
../cleanup.sh
```

## The scripts

### `prep.sh`
`prep.sh` takes a path to a PDF file, a start page number, and an optional end page number and produces two directories that follow this naming schema: `Congress_Session_StartPageNumber(_OptionalEndPageNumber)` and `Congress_Session_StartPageNumber(_OptionalEndPageNumber).bak` (a backup of the other directory in case you make a mistake while editing). Inside each directory are
- a CSV containing metadata extracted from the first line of each bill summary
- several text files containing the summaries extracted from the specified pages of the PDF.

### `spell_check_and_line_mark.sh`
`spell_check_and_line_mark.sh` needs a new name, but it currently runs a `sed` script that replaces some Unicode characters like double quotes and emdashes with ASCII equivalents and eliminates some weird stray OCR artifacts. It then puts the user into `aspell` to do some spell-checking, and finally opens `nvim` to allow for manual editing.

### `cleanup.sh`
`cleanup.sh` does some final spell-checking, opens the text files for a final once over, and copies the names of the text files to the clipboard for pasting into a spreadsheet. It also removes backup files and directories.

to be continued...
