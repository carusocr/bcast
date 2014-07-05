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
$searchterm = ARGV[0]
def scrape_youtube
  visit('https://www.youtube.com')
  page.driver.browser.manage.window.resize_to(800,1000)
  page.fill_in('masthead-search-term', :with => "#{$searchterm}")
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
end

def scrape_vimeo

  upload_date = 'year'  #can be day/week/month/year/any

  visit('https://vimeo.com/watch')
  # can visit vimeo.com/search and avoid first searchclick
  # different search name though:
  # page.fill_in('q', :with => 'changing tire')
  # page.click_button('Find') <---cleaner than page.first
  # gets to same results page
  page.driver.browser.manage.window.resize_to(800,1000)
  page.first(:button,'Search').click
  page.fill_in('search_field', :with => "#{$searchterm}")
  page.first(:button,'Search').click
  sleep 1
  max_results = first(:xpath,"//section[@id = 'search_results_help']/p/em").text.sub(',','')[/(\d+)/,1].to_i
  sleep 1
  puts max_results
  page.all(:xpath,"//li[contains(@id, 'clip_')]/a").each do |clip|
    title = clip[:title]
    url = clip[:href]
    puts "#{title}\t#{url}\n"
  end

=begin

Using Vimeo advanced options:

page.first(:xpath,"//a[@class='advanced_options']").click

Setting min/max durations:

page.fill_in('duration_min', :with => "#{$mindur}")
page.fill_in('duration_max', :with => "#{$maxdur}")

Filtering by date uploaded...simpler method of selecting from dropdowns?

find("option[value=upload_date]").click

Clicking through to next page:

find(:xpath,"//li[@class='pagination_next']").click

Finding max page results:

max_results = first(:xpath,"//section[@id = 'search_results_help']/p/em").text.sub(',','')[/(\d+)/,1].to_i

=end

end

scrape_vimeo
