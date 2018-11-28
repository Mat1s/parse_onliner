require 'capybara'
require_relative 'config'

class ParseOnliner
  REG_LINKS = /https:\/\/\w*.onliner.by\/\d{4}\/\d{2}\/\d{2}\/\S*/i
  REG_IMAGE = /https:\/\/\w*.onliner.by\/\S*.jpeg/i

  def initialize
    Configure.new
    @browser = Capybara.current_session
  end

  def process_data
    @browser.visit 'https://www.onliner.by/'
    links = links(REG_LINKS)
    collect_information(links)
  end

  def resize_window_by(size)
    if Capybara.current_session.driver.browser.respond_to? 'manage'
      Capybara.current_session.driver.browser
      .manage.window.resize_to(size[0], size[1])
    end
  end

  def links(reg_links)
    @browser.all('a').map { |a| a['href'] }
    .select { |a| a if reg_links.match(a) && !/\#/.match(a) }
    .uniq!.sort!
  end

  def collect_information(links)
    output = []
    links.each do |link|
      begin
        @browser.visit(link)
        puts @browser.current_url
        title = @browser.first('.news-header__title div').text
        image = @browser.first('.news-header__image').native
                .css_value('background-image').match(REG_IMAGE).to_s
        all_text = ''
        p_tags = @browser.all('p')
        p_tags.each do |p_tag|
          all_text << p_tag.text
          break if all_text.length > 196
        end
        description = all_text[0..196] + '...'
        inf = [title, image, description]
        output << inf
      rescue Net::ReadTimeout => e
        p e.message
        @browser.driver.quit
        sleep 5
        @browser.visit 'https://www.onliner.by/'
        retry
      end
    end
    output
  end
end
