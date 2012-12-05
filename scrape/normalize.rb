#!/bin/ruby


#TODO
#1. Clean up external resources (so we don't have to normalize
#   the iso stuff every time we iterate, for instance; Add
#   Katie's custom iso codes at this point
#2. Add support for multiple languages (for now tokenize is just 
#   an uncalled method

require 'csv'
require 'nokogiri'
require 'active_support/core_ext/string/conversions.rb'



class ScraperUtils
  @@iso_6393_codes = File.open("lib/iso-639-3_Name_Index_20120816.tab", 'r').readlines
  @@iso_country_codes = Nokogiri::XML(open("lib/country_names_and_code_elements_xml.htm"))
  match_dict = {}

  #Levenshtein implementation courtesy of wikipedia
  def levenshtein(a, b)
    case
    when a.empty? then b.length
    when b.empty? then a.length
    else [(a[0] == b[0] ? 0 : 1) + levenshtein(a[1..-1], b[1..-1]),
          1 + levenshtein(a[1..-1], b),
          1 + levenshtein(a, b[1..-1])].min
    end
  end


  #Function to return iso code for each language
  def get_iso_lang(language)
    best_match = ["UNK", language.length]

    @@iso_6393_codes.each do |line|
      iso_lang = normalize(line.split("\t")[1])
      n_lang = normalize(language[0])
      ldist = levenshtein(iso_lang, n_lang)
      if ldist < best_match[1]
        best_match = [iso_lang[0], ldist]
      end
    end
    return best_match

  end

  #Function to return iso code for each country
  def get_iso_country(country)
    @@iso_country_codes.xpath("//ISO_3166-1_Entry").each do |code|
      if (country.upcase == code.xpath("//ISO_3166-1_Country_name").to_s)
        return code.xpath("//ISO3166-1_Alpha-2_Code_element").to_s
      else
        return "UNK"
      end
    end
  end


  #Helper function for cleaning up language data
  def tokenize(language)
    #Scrubs out parentheticals
    return language.gsub(/\(|\)|\-/, "").split(/\/|\&amp\;|,|and/)
  end

  #Helper function 
  def normalize(string)
    return string.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').split.sort.join(" ").downcase.to_s
  end

  #Helper function to get delta time in seconds
  def get_time_diff(time)
    return (time*60*60*24).to_i
  end

end
