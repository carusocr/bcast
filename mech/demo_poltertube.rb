#!/usr/bin/env ruby

=begin

youtube searcher + crawler test
This is a demo version that uses Selenium for a more visual
presentation. Production version isn't going to bother with 
navigating to buttons, but instead will construct URLs 
and visit them directly.


TASKS:

1. Add database connection.
2. Read options from db.
3. Integrate into downloader/converter.

=end

require 'capybara'

Capybara.current_driver = :selenium
include Capybara::DSL

$pagecount = 3  #trimmed down for demo/testing
searchterm = ARGV[0]
visit('https://www.youtube.com')
sleep 1
page.driver.browser.manage.window.resize_to(800,1000)
sleep 1
page.fill_in('masthead-search-term', :with => "#{searchterm}")
sleep 1
page.first(:button,'Search').click
sleep 1

#parse options and click on relevant filters
page.find(:button,'Filters').click
sleep 1
page.find(:link,'Creative Commons').click
sleep 1
page.find(:button,'Filters').click
sleep 1
page.find(:link,'Short').click
sleep 1

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

sleep 2

for i in 2..$pagecount
  puts "Visiting page #{i}..."
  page.find(:link,'Next').click
  sleep 2
  page.all(:xpath,"//div[@class='yt-lockup-content']").each do |zug|
    url = zug.first(:xpath,"./h3/a")[:href]  
    if url =~ /list=/
      next
    end
    duration = zug.first(:xpath,"../div/a/span[@class='video-time']").text  
    title = zug.first(:xpath,"./h3/a")[:text] 
    puts "#{title}\t#{duration}\t#{url}"
  end
  sleep 2
#what's with the text dump after this loop?!?
#text dumps on playlists...exclude these plus user channel links!
end
