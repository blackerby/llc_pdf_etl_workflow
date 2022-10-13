#!/usr/bin/env ruby

#   Experimenting with the ruby `pdf-reader` gem. Its text output is way different from what
#   PyPDF2 returns. When text extracted by `pdf-reader` is printed, it looks virtually like
#   the page it came from in terms of formatting. But, at least on page 26 of 74_2.pdf, PyPDF2 is far
#   more accurate. There are some characters that `pdf-reader` ignores or throws away or something.
#   I wish it worked, though. It prints "\n\n" between each bill summary, which makes splitting the
#   summaries, much, much easier. I might return to this experiment later.

require 'pdf-reader'

ELEMENT_COUNT = 7 # full header, bill type, bill number, sponsor(s), action date, committee, text
CONGRESS_POSITION = 2
SESSION_POSITION = 3
MONTHS = {
  'January' => '01',
  'February' => '02',
  'March' => '03',
  'April' => '04',
  'Apr.' => '04',
  'May' => '05',
  'June' => '06',
  'July' => '07',
  'August' => '08',
  'September' => '09',
  'October' => '10',
  'November' => '11',
  'December' => '12'
}
HEADER_PATTERN = /(((?:S|H)\.? (?:R\.? (?:J\.? Res\. ?)?)?)(\w{1,5})\.? ((?:M(?:r|essrs)\.) .+)(?:;|,) (\w{1,9} \d{1,2}, \d{4})\.?\ \(([a-zA-Z ]+)\)(?:\.|.+\.|:|.+:))/
DATE_PATTERN = /([JFMASOND][.a-z]{2,8}) (\d{1,2})[-—.,;: ]( \d{4})?/

FILEPATH = '../../74_2.pdf'

def extract_text(start_page, end_page = nil)
  reader = PDF::Reader.new(FILEPATH)
  end_page ||= start_page
  (start_page..end_page).map(&->(page_num) { reader.page(page_num).text })
end

def group_summaries(text)
  # omit the first part of the match, typically a page number
  text.flat_map(&->(s) { s.split(HEADER_PATTERN)[1..].each_slice(ELEMENT_COUNT).to_a })
end

def format_summary_text(text)
  text.split(/ {10}/)
      .map(&:strip)
      .map(&->(s) { s.gsub(/\n +/, ' ') })
      .join("\n")
end

def parse_summaries(raw_summaries)
  metadata = []
  summaries = []
  text_file_names = []

  raw_summaries.each do |rs|
    header, bill_type, bill_number, sponsor, date, committee, text = rs
    bill_type_lower = bill_type.downcase.gsub(' ', '').gsub('.', '')
    metadata << [bill_type.strip, bill_number, sponsor, date, committee]
    summaries << header + format_summary_text(text)
    text_file_names << "#{File.basename(FILEPATH, '.pdf')}_#{bill_type_lower}#{bill_number}"
  end
  [metadata, summaries, text_file_names]
end
