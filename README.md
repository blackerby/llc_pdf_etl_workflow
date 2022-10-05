# Semi-automated workflow for CRS Bill Digest Summaries

This repository contains scripts I'm using to speed up the workflow for my Fall 2022 Law Library of Congress Remoted Metadata Internship. Much of the work is done by the python script, and the shell scripts are used to automate usage of some command-line text-processing utilities. The scripts rely heavily on `aspell`, `nvim`, `tr`, and `sed`. There's even a line of `awk` in there.

The workflow generally follows this order:
```bash
./prep.sh path_to_pdf start_page end_page (optional)
cd directory_created_by_prep
../spell_check_and_line_mark.sh
../munge.sh
../cleanup.sh
```

I'll add more detail to this README over time, and may eventually write a blog post about it.
