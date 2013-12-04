#!/usr/bin/env ruby

require 'mechanize'
require 'nokogiri'

agent = Mechanize.new

page = agent.get('http://google.com/')

page.links_with(:text=>'News').each do |link|
	puts link.text
end

#pp page

goog_form = page.form('f')
goog_form.q = 'perl vs ruby mechanize'

page = agent.submit(goog_form)
pp page
