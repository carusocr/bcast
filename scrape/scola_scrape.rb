#Author: Benjamin Bascom
#SCOLA Scraper v 0.0
#Date: 12/3/2012

#NOTES:
#End Time of last scheduled program for a particular day often falls in the next day
#Beginning to think this doesn't matter as we define a program as a start time (which always takes place in a particular day) + duration

#TODO
#1. Add support for multiple Languages on Line
#2. Add interfrace with table.rb which should contain all our methods for writing
#   to and reading from the db


#!/bin/ruby
require 'rubygems'
require 'openuri'
require 'nokogiri'
require 'mysql'
require 'date'
require 'normalize' 

class Scraper
  @utils = ScraperUtils.new
  
  def scrape
    (1...8).each do |page_num|
      item = Nokogiri::HTML(open("www.scola.org/scola/ProgramSchedule.aspx?ChnlId=#{page_num}"))

      schedule = item.css("span[id *= ProgramSchedule]")
      programs = []

      schedule.each do |i|
        if /_ctl(\d*)_/.match(i.to_s)
          programs << /_ctl(\d*)_/.match(i.to_s)[1]
        end
      end

      ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].each do |day|
        programs.uniq.each do |program|
          ["StartTime", "EndTime", "Country", "Language"].each do |field|
          
            schedule.each do |i|
              if /#{field}/.match("StartTime")
                #Can't save in starttime in the format since automatically fills 
                #the year/month etc fields with todays values
                start_time = Date.strptime(day + ":" + i.to_s, '%a:%H:%M')
              elsif /#{field}/.match("EndTime")
                end_time = Date.strptime(day + ":" + i.to_s, '%a:%H:%M')
              
              elsif /#{field}/.match("Language")
                n_lang = i.to_s
              elsif /#{field}/.match("Country")
                n_country = utils.normalize(i.to_s)
              end
            
            end
          end
        end

        duration = utils.get_time_diff(end_time-start_time)
        last_seen = Date.today
        iso_cn = utils.get_iso_country(n_country)
        iso_ln = utils.get_iso_lang(n_lang)

        #Unsupported - Multiple languages on line
        prog_id = iso_ln[0].upcase + "_" + page_num + "_" + start_time.to_s + "_" + duration
        rows.append(prog_id, iso_ln[0], iso_cn, start_time, duration, last_seen, n_lang, n_country, page_num)

      end
      
    end
  end
end



