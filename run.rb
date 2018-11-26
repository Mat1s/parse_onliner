require_relative 'lib/parse_onliner'
require_relative 'lib/csv_output'

par = ParseOnliner.new
# par.resize_window_by [1024, 768]
result = par.process_data
csv_file = CSVOutput.new(result)
csv_file.output_information
