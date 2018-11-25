require 'capybara'
Capybara.register_driver :selenium do |app|  
  Capybara::Selenium::Driver.new(app,
    browser: :chrome, 
    desired_capabilities: {
      "chromeOptions" => {
        "args" => %w{ window-size=1366,768 }
      }
    }
  )
end
Capybara.javascript_driver = :chrome
Capybara.configure do |config|  
  config.default_max_wait_time = Random.new.rand(10..15)
  config.default_driver = :selenium
end