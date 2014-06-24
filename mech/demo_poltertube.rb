#!/usr/bin/env ruby

=begin

youtube searcher + crawler test
This is a demo version that uses Selenium for a more visual
presentation. Production version isn't going to bother with 
navigating to buttons, but instead will construct URLs 
and visit them directly.

=end

require 'capybara'

Capybara.current_driver = :selenium
include Capybara::DSL

$pagecount = 3  #trimmed down for demo/testing
searchterm = ARGV[0]
visit('https://www.youtube.com')
page.fill_in('masthead-search-term', :with => "#{searchterm}")
page.first(:button,'Search').click

#handle max pages to crawl
total_result_pages = page.first(:xpath,"//p[@class='num-results']").text.gsub(/\D/,'').to_i/20
unless $pagecount #skip if pagecount has been specified in args
    $pagecount = (total_results < max_pages) ? total_results : max_pages
end
puts $pagecount

#parse options and click on relevant filters
#page.find(:button,'Filters').click
#page.find(:link,option).click

#maybe for i in 1..maxpages, scrape links and then click next
#page.find(:link,'Next').click

#gets title + duration + url for items on first page
page.all(:xpath,"//div[@class='yt-lockup-content']").each do |zug|
  duration = zug.first(:xpath,"../div/a/span[@class='video-time']").text  
  title = zug.first(:xpath,"./h3/a")[:text] 
  url = zug.first(:xpath,"./h3/a")[:href]  
  puts "#{title}\t#{duration}\t#{url}"
end

sleep 1

for i in 2..$pagecount
  puts "Visiting page #{i}..."
  page.find(:link,'Next').click
  sleep 2
  page.all(:xpath,"//div[@class='yt-lockup-content']").each do |zug|
    duration = zug.first(:xpath,"../div/a/span[@class='video-time']").text  
    title = zug.first(:xpath,"./h3/a")[:text] 
    url = zug.first(:xpath,"./h3/a")[:href]  
    puts "#{title}\t#{duration}\t#{url}"
    sleep 1
  end
  sleep 2
#what's with the text dump after this loop?!?
end
