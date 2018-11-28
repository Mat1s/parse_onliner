class Configure
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app,
      browser: :chrome,
      desired_capabilities: {
        "chromeOptions" => {
          "args" => %w[window-size=1366,768]
        }
      })
  end
  Capybara.javascript_driver = :selenium
  Capybara.default_max_wait_time = 15
  Capybara.default_driver = :selenium
end

