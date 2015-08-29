#!/usr/bin/env ruby
=begin
Script to log in to Google account, navigate to a YouTube video, and make a comment.

Future features:

1. Automated search for video based on keywords. 
2. Leave comment with content that varies depending on video title/subject.
3. Maintain database record of urls+comments, revisit and harvest replies.

*** Using youtube_it no longer works since YouTube changed their API and the
gem has been apparently abandoned. Seek alternatives.

=end
 

require 'capybara'
require 'youtube_it'
require 'trollop'
require 'yaml'
Capybara.current_driver = :selenium

LOGIN_URL = "https://accounts.google.com/ServiceLogin?hl=en"
TESTVID = "https://www.youtube.com/watch?v=mhAU9iBJQTs"
cfgfile = 'dev.cfg'
cnf = YAML::load(File.open(cfgfile))
devkey = cnf['goog']['devkey']

opts = Trollop::options do
  banner <<-EOS

Add comment to a YouTube video.

Usage: commenter.rb -u <username> -p <password> -v <video id> -c <comment to add>

EOS
  opt :vid_id, "Youtube ID string of video", :short => 'v', :type => String
  opt :comment, "Comment to add to video", :short => 'c', :type => String
  opt :user, "Google login", :short => 'u', :type => String
  opt :pwd, "Google pass", :short => 'p', :type => String
end

client = YouTubeIt::Client.new(:username => opts[:user], :password => opts[:pwd], :dev_key => devkey)
client.add_comment(opts[:vid_id],opts[:comment])

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
