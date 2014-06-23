#!/usr/bin/env ruby

=begin

youtube searcher + crawler test

=end

require 'capybara'

Capybara.current_driver = :selenium
include Capybara::DSL

searchterm = ARGV[0]
visit('https://www.youtube.com')
page.fill_in('masthead-search-term', :with => "#{searchterm}")
page.first(:button,'Search').click
