#!/usr/bin/env ruby

=begin

Script to open up either a capybara or poltergeist session, start pry, 
visit a page. Used to get to an interactive prompt where I can test xpaths.

=end

require 'pry'
require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'

abort <<EOF unless (ARGV[0] && ARGV[0] =~ /sl|pg/) && (ARGV[1] && ARGV[1] =~ /http/)

Script must be called with either 'sl' or 'pg' argument to specify
visible (selenium) or headless (poltergeist) browser, and a
valid URL.

Example: pry_crawl_preload.rb sl https://www.ldc.upenn.edu

EOF

browser_type = ARGV[0]
site = ARGV[1]

def load_poltergeist(site)
  Capybara.register_driver(:poltergeist) do |app|
    Capybara::Poltergeist::Driver.new(app, js_errors: false,
    phantomjs_options: ['--ignore-ssl-errors=yes','--ssl-protocol=any'])
  end
  Capybara.default_driver = :poltergeist
  Capybara.javascript_driver = :poltergeist
  web = Capybara.current_session
  web.visit site
  binding.pry
end

def load_selenium(site)
  Capybara.register_driver :chrome do |app|
    Capybara::Selenium::Driver.new(app, :browser => :chrome)
  end
  Capybara.javascript_driver = :chrome
  Capybara.default_driver = :chrome   #should this be current or default? Explore reasons.
  include Capybara::DSL
  visit site
  binding.pry
end

if browser_type == 'sl'
  load_selenium(site)
else
  load_poltergeist(site)
end
