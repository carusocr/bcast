#Author: Benjamin Bascom
#SCOLA Scraper v 0.0
#Date: 12/3/2012

#NOTES:
#End Time of last scheduled program for a particular day often falls in the next day
#Beginning to think this doesn't matter as we define a program as a start time (which always takes place in a particular day) + duration


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
  @@utils = ScraperUtils.new
  @@scola_table = ScolaRecord
  
  def scrape
    (1...8).each do |page_num|
      item = Nokogiri::HTML(open("http://www.scola.org/scola/ProgramSchedule.aspx?ChnlId=#{page_num}"))

      schedule = item.css("span[id *= ProgramSchedule]")
      programs = []

      schedule.each do |i|
        if /_ctl(\d*)_/.match(i.to_s)
          programs << /_ctl(\d*)_/.match(i.to_s)[1]
        end
      end
      
      ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].each do |day|
        prog_data = {}
        programs.uniq.each do |program|
          prog_data[program] = {}
          schedule.each do |i|
            if /StartTime/.match("#{i.to_s}") and /#{program}/.match("#{i.to_s}")

              prog_data[program]['start_time'] = Date.strptime(day + ":" + i.content, '%a:%H:%M')
            elsif /EndTime/.match("#{i.to_s}") and /#{program}/.match("#{i.to_s}")

              prog_data[program]['end_time'] = Date.strptime(day + ":" + i.content, '%a:%H:%M')
            elsif /Language/.match("#{i.to_s}") and /#{program}/.match("#{i.to_s}")

              prog_data[program]['language'] = @@utils.tokenize(i.content)
            elsif /Country/.match("#{i.to_s}") and /#{program}/.match("#{i.to_s}")

              prog_data[program]['country'] = @@utils.normalize(i.content)
            end            
          end


          if !program == "00"
            end_time = prog_data[program]['end_time']
            start_time = prog_data[program]['start_time']
            n_country = prog_data[program]['country']
            
            num_lang = prog_data[program]['language']
            
            if !start_time.nil? and !end_time.nil?
              duration = @@utils.get_time_diff(end_time-start_time)
            end

            last_seen = Date.today

            iso_cn = @@utils.get_iso_country(n_country)
            

            num_lang.each do |lang|
              
              iso_ln = @@utils.get_iso_lang(n_lang)
              prog_id = iso_ln[0].upcase + "_" + page_num + "_" + start_time.to_s + "_" + duration
              puts "#{prog_id}, #{start_time}, #{duration}, #{iso_cn}, #{iso_ln} "
              #prog_query = @@scola_table.new(:prog_id => prog_id)
              

              #row = @@scola_table.new(:prog_id => prog_id, :iso_ln => iso_ln,
              #                        :iso_cn => iso_cn, :start_time => start_time,
              #                        :duration => duration, :l_seen => last_seen,
              #                        :n_lang => lang, :n_country => n_country,
              #                        :channel => page_num)
              #puts row

            end
          end


        end      
      end
    end
  end
end


