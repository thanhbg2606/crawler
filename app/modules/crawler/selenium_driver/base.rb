module Crawler

  module SeleniumDriver

    module Base
      attr_accessor :driver, :wait

      def create_driver headless = true, *args
        options = Selenium::WebDriver::Chrome::Options.new

        if headless
          options.add_argument('--headless')
          options.add_argument('--disable-dev-shm-usage')
          options.add_argument('--no-sandbox')
        end

        driver = Selenium::WebDriver.for :chrome, options: options
      end

      def create_wait
        wait = Selenium::WebDriver::Wait.new(:timeout => 3)
      end

      def css location, action
        driver.find_elements(:css, location).map{ |item| get_value(item, action) }
      rescue Selenium::WebDriver::Error::NoSuchElementError => e
        Rails.logger.warn(e.message)
        Rails.logger.warn(driver.find_element("xpath", "//*").attribute("outerHTML"))
        nil
      end

      def at_css location, action
        element = driver.find_element(:css, location)
        get_value(element, action)
      rescue Selenium::WebDriver::Error::NoSuchElementError => e
        Rails.logger.warn(e.message)
        Rails.logger.warn(driver.find_element("xpath", "//*").attribute("outerHTML"))
        nil
      end

      def is_loaded?
        is_loaded = nil
        if driver.execute_script("return document.readyState") == "complete"
          is_loaded =  true
        end
        is_loaded
      end

      def close_driver
        driver.quit
      end

      private

      def get_value element, action
        if action.empty?
          action = "text"
        end

        element.attribute(action)
      rescue StandardError => e
        Rails.logger.error(e)
        nil
      end
    end
  end
end
