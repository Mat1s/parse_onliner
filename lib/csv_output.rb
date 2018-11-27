require 'csv'

class CSVOutput
  def initialize(results)
    @file = 'results/default.csv'
    @results = results
  end

  def change_csv
    puts 'Tape new file name >>'
    f = gets.chomp 
    @file = f if f =~ /\S*.csv/i && f != ''
  end

  def output_information
    CSV.open("#{@file}", "wb") do |csv|
      csv << ["title", "image", "description"]
      @results.each { |line| csv << line }
    end
  end
end
