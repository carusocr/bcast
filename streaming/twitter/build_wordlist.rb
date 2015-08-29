#!/usr/bin/env ruby
#scrapes 101languages.net and builds list of words for use in Twitter collection

require 'capybara'
require 'capybara/poltergeist'
Capybara.current_driver = :poltergeist
include Capybara::DSL

abort "Enter a language!" unless ARGV[0]
lang = ARGV[0]
source_site = "http://www.101languages.net/#{lang}/#{lang}-word-list"

visit source_site

words=[]
rows = page.all(:xpath,"//tr[@dir='ltr']")
rows.each do |r|
  wordset = r.text.sub(/^to /,'').split[1..-1].join(",").sub(/\(.+\)/,'').gsub(',,',',').gsub(';','')
  words << wordset
end
puts words.join(",").split(',')
