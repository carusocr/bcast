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
TESTVID = "https://www.youtube.com/watch?v=mhAU9iBJQTs"




class GoogleLogin
  include Capybara::DSL
    def login
      visit(LOGIN_URL)
      page.fill_in('Email', :with => EMAIL)
      page.fill_in('Passwd', :with => PASSWD)
      page.click_button('Sign in')
    end
    def comment
      visit(TESTVID)
      #scroll down page so comments frame loads...
      page.execute_script "window.scrollBy(0,400)"
      sleep 2
      # figure out how to list scripts
      # check out this page: http://help.dottoro.com/ljhrmrfb.php#dhtmlMethods
      comments = page.first(:xpath,"//iframe")[:id]
    end
end

t = GoogleLogin.new
t.login
t.comment
sleep 1
# need to scroll down a page so comments iframe loads
# to scroll down a page: 
#switch to iframe with comments!
#comments = page.first(:xpath,"//iframe")[:id]
# page.driver.browser.switch_to.frame comments
# find comment box
# page.first('span', :text => 'Share your thoughts').click
# NEED TO LOG IN FIRST, OTHERWISE REDIRECTS TO LOGIN

#set value of text in element?
# /html/body/div/div/div/div/div[2]/div[2]/div/div/div[5]/div/div/div
# //*[@id=":u.f"]
# 
