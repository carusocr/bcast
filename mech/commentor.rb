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
require 'capybara/dsl'	#do I need to include this?

Capybara.run_server = false
Capybara.current_driver = :selenium #switch to poltergeist later
