#!/usr/bin/env ruby

require 'mechanize'
require 'nokogiri'

agent = Mechanize.new

page = agent.get('http://google.com/')

page.links.each do |link|
	puts link.text
end
