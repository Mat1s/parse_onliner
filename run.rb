require_relative 'lib/parse_onliner'
require_relative 'lib/csv_output'

par = ParseOnliner.new
par.resize_window_by [1024, 768]
result = par.process_data
csv_out = CSVOutput.new(result)
csv_out.change_csv
csv_out.output_information
