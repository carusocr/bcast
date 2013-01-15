1#Author: Benjamin Bascom
#SCOLA Scraper v 0.0
#Date: 12/3/2012


#!/bin/ruby
require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'mysql'
require 'date'
require './normalize' 
require './db/table'
require 'pp'

class Scraper
  # Some utility methods I wrote to help with unicode normalization and tokenizing the broadcast data
  @@utils = ScraperUtils.new
  # Basically just a wrapper class that inherits from ActiveRecord
  @@scola_table = ScolaRecord
  
  def scrape
    (1...9).each do |page_num|
      item = Nokogiri::HTML(open("http://www.scola.org/scola/ProgramSchedule.aspx?ChnlId=#{page_num}"))

      schedule = item.css("span[id *= ProgramSchedule]")
      programs = []

      # Each program is identified in the DOM by the intersection of the day on which it occurs (sometimes mispelled, but
      # never before the first 3 letters) and a program number
      schedule.each do |i|
        if /_ctl(\d*)_/.match(i.to_s)
          programs << /_ctl(\d*)_/.match(i.to_s)[1]
        end
      end
      
      ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].each do |day|
        prog_data = {}
        programs.uniq.each do |program|
          prog_data[program] = {}
          prog_data[program]['day'] = day

          schedule.each do |i|
            if /StartTime/.match("#{i.to_s}") and /#{day}/.match("#{i.to_s}") and /_ctl#{program}_/.match("#{i.to_s}")
              prog_data[program]['st_raw'] = i.content.split(":").join("")
              prog_data[program]['start_time'] = DateTime.strptime(i.content, '%H:%M')
            elsif /EndTime/.match("#{i.to_s}") and /#{day}/.match("#{i.to_s}") and /_ctl#{program}_/.match("#{i.to_s}")

              prog_data[program]['end_time'] = DateTime.strptime(i.content, '%H:%M')
            elsif /Language/.match("#{i.to_s}") and /#{day}/.match("#{i.to_s}") and /_ctl#{program}_/.match("#{i.to_s}")

              prog_data[program]['language'] = @@utils.tokenize(i.content)
            elsif /Country/.match("#{i.to_s}") and /#{day}/.match("#{i.to_s}") and /_ctl#{program}_/.match("#{i.to_s}")

              prog_data[program]['country'] = i.content
            end            
          end

          # There are some empty DOM elements that fall into the intersection of day/program code, we ignore them by requiring a match on language
          # this would also obviously dump 'programs' that have no or an empty language field which I think is appropriate
          if prog_data[program]['language']

            end_time = prog_data[program]['end_time']
            start_time = prog_data[program]['start_time']
            n_country = prog_data[program]['country']            
            num_lang = prog_data[program]['language']

            if !start_time.nil? and !end_time.nil?
              duration = @@utils.get_time_diff(end_time-start_time)
              if duration < 0
                duration = duration + 86400
              end
            end

            last_seen = Date.today

            # Hard code in Kosovo here since it's not on the table, possibly could be pushed to normalize.rb for more consistency
            if n_country != nil and n_country.downcase == 'kosovo'
              iso_cn = "XK"
            else
              iso_cn = @@utils.get_iso_country(n_country)
            end

            # Because we call multilingual programs essentially 2 programs with the same starttime and duration we need to create a row for each distinct language that that program is in. The tokenize function in normalize.rb seems to do this well enough for the scola idiom as it's currently implemented but parsing that is not an easy task and could easily be disrupted if they change their conventions.
            num_lang.each do |lang|
              lang = lang.strip()
              iso_ln = @@utils.get_iso_lang(lang)[0]
              prog_id = iso_ln.upcase + "_" + page_num.to_s + "_" + prog_data[program]['st_raw'] + "_" + duration.to_s
              st_time = prog_data[program]['st_raw'][0..1] + ":" + prog_data[program]['st_raw'][2..3] + ":" + prog_data[program]['st_raw'][4..5]

              #This is where we should either create a record or update it as necessary
              begin
                @@scola_table.where(:prog_id => prog_id).first!(:iso_ln => iso_ln, :iso_cn => iso_cn, :day => day, :start_time => st_time, :duration => duration, :l_seen => last_seen,  :n_lang => lang, :n_country => n_country, :channel => page_num)
              rescue 
                @@scola_table.where(:prog_id => prog_id).create(:iso_ln => iso_ln, :iso_cn => iso_cn, :day => day, :start_time => st_time, :duration => duration, :l_seen => last_seen, :f_seen => last_seen, :n_lang => lang, :n_country => n_country, :channel => page_num)
              end
                  
            end
          end
          
          
        end      
      end
      
    end
  end
end

# Not really a ruby way of doing stuff but, convenient for this application
if __FILE__ == $0
  this_scraper = Scraper.new
  this_scraper.scrape
end
