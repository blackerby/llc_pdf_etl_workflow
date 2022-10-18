#!/usr/bin/env python

import argparse
import sys
import re
import csv
from pathlib import Path

from PyPDF2 import PdfReader
from more_itertools import chunked

ELEMENT_COUNT = (
    7  # full header, bill type, bill number, sponsor(s), action date, committee, text
)
CONGRESS_POSITION = 2
SESSION_POSITION = 3
MONTHS = {
    "January": "01",
    "February": "02",
    "Feb.": "02",
    "March": "03",
    "April": "04",
    "Apr.": "04",
    "May": "05",
    "June": "06",
    "July": "07",
    "August": "08",
    "September": "09",
    "October": "10",
    "November": "11",
    "December": "12",
}
HEADER_PATTERN = re.compile(
    r"(((?:S|H)\.? (?:R\.? (?:J\.? Res\. ?)?)?)(\w{1,5})\.? ((?:M(?:r|essrs)\.) .+?)(?:[;,:])? (\w{1,9} \d{1,2}, \d{4})\.?\ ?(?:\(([a-zA-Z ]+)\))?(?:\.|.+\.|:|.+:)?)"
)
DATE_PATTERN = re.compile(r"([JFMASOND][.a-z]{2,8}) (\d{1,2})[-—.,;: ]( \d{4})?")


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "file_path", help="path to a bill digest PDF, e.g., ../74_2.pdf"
    )
    parser.add_argument(
        "start_page",
        help="PDF page number (not printed page number) for where program should start working",
        type=int,
    )
    parser.add_argument(
        "end_page",
        help="last PDF page number (not printed page number) program should process",
        type=int,
        nargs="?",
    )
    return parser.parse_args()


def name_output_file(file_stem, start_page, end_page):
    if end_page:
        return "_".join([file_stem, str(start_page), str(end_page)]) + ".csv"
    else:
        return "_".join([file_stem, str(start_page)]) + ".csv"


def extract_summaries_and_metadata(file_path, start_page, end_page):
    metadata = []
    summaries = []
    text_file_names = []
    reader = PdfReader(file_path)
    file_stem = file_path.stem

    if end_page == None:
        end = start_page + 1
    else:
        end = end_page

    for i in range(start_page, end):
        page_text = reader.pages[i].extract_text()

        first_header_pos = re.search(HEADER_PATTERN, page_text).start()
        page_text = page_text[first_header_pos:]
        raw_summaries = re.split(HEADER_PATTERN, page_text)[1:]
        raw_summaries = list(chunked(raw_summaries, ELEMENT_COUNT))

        for item in raw_summaries:
            header, bill_type, bill_number, sponsor, date, committee, text = item
            formatted_bill_type = bill_type.strip()
            lower_bill_type = bill_type.lower().replace(" ", "").replace(".", "")
            summary = header + text
            metadata.append(
                [formatted_bill_type, bill_number, sponsor, date, committee]
            )
            summaries.append(summary)
            text_file_names.append(f"{file_stem}_{lower_bill_type}{bill_number}")

    return (metadata, summaries, text_file_names)


def format_latest_action_dates(summaries):
    actions = []
    date_tags = []
    intro_dates = []

    for summary in summaries:
        lines = summary.splitlines()
        intro_dates.append(re.findall(DATE_PATTERN, lines[0])[0])
        if len(lines) > 1:
            actions.append(lines[1])
        else:
            actions.append("")

    for action in actions:
        intro_date = intro_dates[actions.index(action)]
        intro_year = intro_date[2]
        dates = re.findall(DATE_PATTERN, action)
        if dates:
            default_year = dates[0][2] or intro_year
            date = list(dates[-1])
            if date[2] == "":
                date[2] = default_year
        else:
            date = list(intro_date)
        date[0] = MONTHS[date[0]]
        date_tag = f"{date[2].strip()}{date[0]}{date[1].zfill(2)}"
        date_tags.append(date_tag)

    return date_tags


def format_output_files(text_file_names, date_tags):
    if len(text_file_names) != len(date_tags):
        print("Text files names list and date tags list are not the same length.")
        sys.exit(1)
    filenames = map(
        lambda name: "_".join(name) + ".txt", list(zip(text_file_names, date_tags))
    )
    return list(filenames)


def write_metadata(metadata, output_file_name, congress):
    headers = [
        "congress",
        "session",
        "pl_num",
        "bill_type",
        "bill_number",
        "sponsor",
        "committee",
        "action_red",
        "summary_version_code",
        "report_number",
        "action",
        "action_date",
        "associated_summary_file",
        "questions_comments",
    ]

    with open(output_file_name, "w") as f:
        writer = csv.DictWriter(f, fieldnames=headers)
        writer.writeheader()
        for row in metadata:
            writer.writerow(
                {
                    "congress": congress,
                    "session": "",
                    "pl_num": "",
                    "bill_type": row[0],
                    "bill_number": row[1],
                    "sponsor": row[2],
                    "committee": row[4] or "N/A",
                    "action_red": "",
                    "summary_version_code": "",
                    "report_number": "",
                    "action": "Introduced",
                    "action_date": row[3],
                    "associated_summary_file": "",
                    "questions_comments": "",
                }
            )


def write_summaries(summaries, text_file_names):
    for i in range(len(summaries)):
        with open(text_file_names[i], "w") as f:
            f.write(summaries[i])


if __name__ == "__main__":
    args = parse_args()
    file_path = args.file_path
    start_page = args.start_page
    start_page_index = start_page - 1
    end_page = args.end_page

    file_path = Path(file_path)
    file_stem = file_path.stem
    output_file_name = name_output_file(file_stem, start_page, end_page)

    congress = file_stem[:CONGRESS_POSITION]
    session = file_stem[SESSION_POSITION]

    metadata, summaries, text_file_names = extract_summaries_and_metadata(
        file_path, start_page_index, end_page
    )

    action_dates = format_latest_action_dates(summaries)
    output_file_names = format_output_files(text_file_names, action_dates)

    write_metadata(metadata, output_file_name, congress)
    write_summaries(summaries, output_file_names)
