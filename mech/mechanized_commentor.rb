#!/usr/bin/env ruby

=begin
Name: 
Concept:

1. Agent logs into Google account.
2. Agent navigates to youtube page, using similar search mechanism as with ytvore.
	records URL in database. Doesn't bother downloading video.
3. Enters inflammatory comment based on search criteria. Example, 'parkour is for losers'. 
4. Occasionally checks to see if replies have been generated. Harvests those comments
	into a comments table with URL as foreign key.


Notes: use capybara for now since I've moved to that for stockboy?
=end

require 'capybara'
Capybara.current_driver = :selenium

EMAIL = ARGV[0]
PASSWD = ARGV[1]
LOGIN_URL = "https://accounts.google.com/ServiceLogin?hl=en"




module TrollBot
  class GoogleLogin
    include Capybara::DSL
      def login
        puts LOGIN_URL
      end
  end
end

t = TrollBot::GoogleLogin.new
zug = t.login
# need to scroll down a page so comments iframe loads
# to scroll down a page: window.scrollBy(0,800)"
#switch to iframe with comments!
#comments = page.first(:xpath,"//iframe")[:id]
# page.driver.browser.switch_to.frame comments
# find comment box
# page.first('span', :text => 'Share your thoughts').click
# NEED TO LOG IN FIRST, OTHERWISE REDIRECTS TO LOGIN
