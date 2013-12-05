#!/usr/bin/env ruby
#Google image search is a pain in the ass, start small with Yahoo.
require 'mechanize'
require 'nokogiri'

agent = Mechanize.new

page = agent.get('http://images.search.yahoo.com/')

page.links.each do |link|
	puts link.text
end


img_form = page.form('s')
img_form.p = "maitake"

page = agent.submit(img_form)
pp page
