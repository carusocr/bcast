#!/usr/bin/env ruby

require 'capybara'
require 'youtube_it'
require 'trollop'
Capybara.current_driver = :selenium

LOGIN_URL = "https://accounts.google.com/ServiceLogin?hl=en"
TESTVID = "https://www.youtube.com/watch?v=mhAU9iBJQTs"

opts = Trollop::options do
  opt :comment, "Comment to add to video", :short => 'c', :type => String
end

puts opts[:comment]

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
      page.driver.browser.switch_to.frame comments
      page.first('span',:text => 'Share your thoughts').hover
      page.first('span',:text => 'Share your thoughts').click
      #page.first(:xpath,"//div[contains(@id,':')]").set 'ZUG'
      #sleep 2
      cnode = page.first(:xpath,"//div[contains(@id,':')]",:visible=>false)
      puts "Got a cnode" if !cnode.nil? 
      sleep 2
      #cnode2 = page.first(:xpath,"//div[contains(@id,':')]")
      #puts "Got a second cnode" if !cnode2.nil? 
      page.first(:xpath,"//div[@contenteditable='true']").set 'YOUR CAT IS AWESOME'
      
      
    end
end
