#Author: Benjamin Bascom
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
  @@utils = ScraperUtils.new
  @@scola_table = ScolaRecord
  
  def scrape
    (1...9).each do |page_num|
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

          puts PP.pp(prog_data[program])

          #Program 00 is some kind of placeholder crap
          if not program == "00"

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

            if n_country != nil and n_country.downcase == 'kosovo'
              iso_cn = "XK"
            else
              iso_cn = @@utils.get_iso_country(n_country)
            end

            num_lang.each do |lang|
              lang = lang.chomp()
              iso_ln = @@utils.get_iso_lang(lang)[0]
              prog_id = iso_ln.upcase + "_" + page_num.to_s + "_" + prog_data[program]['st_raw'] + "_" + duration.to_s
              st_time = prog_data[program]['st_raw'][0..1] + ":" + prog_data[program]['st_raw'][2..3] + ":" + prog_data[program]['st_raw'][4..5]


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

if __FILE__ == $0
  this_scraper = Scraper.new
  this_scraper.scrape
end
