#!/usr/bin/env ruby

=begin

youtube searcher + crawler
Differences from demo:

1. Headless and not so sleepy.
2. Will accept set of options on commandline.
3. Connects to database.
4. Integrated into downloader/converter.

=end

require 'capybara'
#require 'capybara/poltergeist'
require 'sequel'
require 'optparse'

Capybara.current_driver = :selenium
include Capybara::DSL

$pagecount = 2  #trimmed down for demo/testing
searchterm = ARGV[0]
visit('https://www.youtube.com')
page.driver.browser.manage.window.resize_to(800,1000)
page.fill_in('masthead-search-term', :with => "#{searchterm}")
page.first(:button,'Search').click

#parse options and click on relevant filters
page.find(:button,'Filters').click
sleep 1
page.find(:link,'Creative Commons').click
sleep 1
page.find(:button,'Filters').click
sleep 1
page.find(:link,'Short').click

#handle max pages to crawl
total_results = page.first(:xpath,"//p[@class='num-results']").text.gsub(/\D/,'').to_f/20
total_result_pages = total_results.ceil
unless $pagecount #skip if pagecount has been specified in args
    $pagecount = (total_result_pages < max_pages) ? total_result_pages : max_pages
end

#gets title + duration + url for items on first page
page.all(:xpath,"//div[@class='yt-lockup-content']").each do |zug|
  url = zug.first(:xpath,"./h3/a")[:href]  
  if url =~ /list=/
    next
  end
  duration = zug.first(:xpath,"../div/a/span[@class='video-time']").text  
  title = zug.first(:xpath,"./h3/a")[:text] 
  puts "#{title}\t#{duration}\t#{url}"
end

for i in 2..$pagecount
  puts "Visiting page #{i}..."
  sleep 1
  page.find(:link,'Next').click
  sleep 1
  page.all(:xpath,"//div[@class='yt-lockup-content']").each do |zug|
    url = zug.first(:xpath,"./h3/a")[:href]  
    if url =~ /list=/
      next
    end
    duration = zug.first(:xpath,"../div/a/span[@class='video-time']").text  
    title = zug.first(:xpath,"./h3/a")[:text] 
    puts "#{title}\t#{duration}\t#{url}"
  end
end
