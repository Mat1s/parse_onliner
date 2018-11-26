require 'capybara'
require 'csv'
require_relative 'config'

class ParseOnliner
  REG_LINK = /https:\/\/\w*.onliner.by\/\d{4}\/\d{2}\/\d{2}\/\S*/i

  def initialize
    Configure.new
    @file = 'results/default.csv'
    @browser = Capybara.current_session
  end

  def process_data
    csv_file = change_csv(@file)
    @browser.visit 'https://www.onliner.by/'
    links = links(REG_LINK)
    collect_information(links, csv_file)
  end  

  def resize_window_by(size)
    Capybara.current_session.driver.browser.
    manage.window.resize_to(size[0], size[1]) if Capybara.current_session.
    driver.browser.respond_to? 'manage'
  end

  def links(reg_main_links)
    @browser.all('a').map { |a| a['href'] }
    .select { |a| a if(reg_main_links.match(a) && !(/\#/.match(a))) }
    .uniq!
  end

  def change_csv(file)
    puts 'Tape new file name >>'
    f = gets.chomp 
    f != '' ? 'results/' + f : file
  end

  def collect_information(links, csv_file)
    CSV.open("#{csv_file}", "wb") do |csv|
      csv << ["title", "image", "description"]
      links.each do |link|
        @browser.visit(link)
        title = @browser.first('.news-header__title div').text
        image = @browser.first('.news-header__image')
                .native.css_value('background-image')
                .match(/https:\/\/\w*.onliner.by\/\S*.jpeg/i).to_s
        all_text = ''
        p_tags = @browser.all('p')
        p_tags.each { |p_tag| all_text << p_tag.text }
        description = all_text[0..196] + '...'
        inf = [title, image, description]
        csv << inf
      end
    end
  end
end


