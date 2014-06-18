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

require 'mysql'
require 'capybara'
require 'capybara/poltergeist'
#require 'capybara/dsl'	#do I need to include this?

EMAIL = ARGV[0]
PASSWD = ARGV[1]

Capybara.run_server = false
Capybara.current_driver = :selenium #switch to poltergeist later
Capybara.app_host = 'http://www.youtube.com'

module CapyTesty
	class Test
		include Capybara::DSL
		def test_google
			visit("https://accounts.google.com/ServiceLogin?hl=en")
			page.fill_in('Email', :with => EMAIL)
			page.fill_in('Passwd', :with => PASSWD)
      page.click_button('Sign in')
			sleep 5
			#after this: visit a youtube page, try to make comment
			# visit("http://www.youtube.com/watch?v=uO4lkv-jLRs")
		end
	end
end

t = CapyTesty::Test.new
t.test_youtube
