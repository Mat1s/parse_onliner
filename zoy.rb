require 'capybara'
require 'csv'
class ParseOnliner
  def initialize
    configure
    @file = 'default.csv'
    @browser = Capybara.current_session
  end

  def process_data
    csv_file = set_csv_file(@file)
    @browser.visit "https://www.onliner.by/"
    regex = create_regexp
    links = get_links(regex)
    collect_information(links, csv_file)
  end  

  def resize_window_by(size)
    Capybara.current_session.driver.browser.
    manage.window.resize_to(size[0], size[1]) if Capybara.current_session.
    driver.browser.respond_to? 'manage'
  end

  def create_regexp
    Regexp.new('https:\/\/\w*.onliner.by\/\d{4}\/\d{2}\/\d{2}\/\S*', true)
  end

  def get_links(reg_main_links)
    @browser.all('a').map { |a| a['href'] }
    .select { |a| a if(reg_main_links.match(a) && !(/\#/.match(a))) }
    .uniq!
  end

  def set_csv_file(file)
    puts 'Tape new file name >>'
    f = gets.chomp 
    f != '' ? f : file
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

  def configure
    Capybara.register_driver :selenium do |app|
      Capybara::Selenium::Driver.new(app,
      browser: :chrome,
      desired_capabilities: {
        "chromeOptions" => {
          "args" => %w[window-size=1366,768]
        }
      })
    end
    Capybara.javascript_driver = :chrome
    Capybara.configure do |config|
      config.default_max_wait_time = Random.new.rand(10..15)
      config.default_driver = :selenium
    end
  end
end

par = ParseOnliner.new
par.resize_window_by [786, 454]
par.process_data
