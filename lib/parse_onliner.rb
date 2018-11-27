require 'capybara'
require_relative 'config'

class ParseOnliner
  REG_LINK = /https:\/\/\w*.onliner.by\/\d{4}\/\d{2}\/\d{2}\/\S*/i
  def initialize
    Configure.new
    @browser = Capybara.current_session
  end

  def process_data
    @browser.visit 'https://www.onliner.by/'
    links = links(REG_LINK)
    collect_information(links)
  end  

  def resize_window_by(size)
    Capybara.current_session.driver.browser.
    manage.window.resize_to(size[0], size[1]) if Capybara.current_session.
    driver.browser.respond_to? 'manage'
  end

  def links(reg_links)
    @browser.all('a').map { |a| a['href'] }
    .select { |a| a if(reg_links.match(a) && !(/\#/.match(a))) }
    .uniq!
  end

  def collect_information(links)
    output = []
    links.each do |link|
      @browser.visit(link)
      title = @browser.first('.news-header__title div').text
      image = @browser.first('.news-header__image')
              .native.css_value('background-image')
              .match(/https:\/\/\w*.onliner.by\/\S*.jpeg/i).to_s
      all_text = ''
      p_tags = @browser.all('p')
      p_tags.each { |p_tag| all_text << p_tag.text; break if all_text.length > 196 }
      description = all_text[0..196] + '...'
      inf = [title, image, description]
      p inf
      output << inf
    end
    output
  end
end
