#!/bin/ruby

#TODO

#1 Add Katie's custom iso codes at this point
#2. Possibly clean up iso langs
#3. clean up iso country (russia get a no hit since russian federation is in the table
#4. Add support for multiple languages (for now tokenize is just 
#   an uncalled method

require 'csv'
require 'nokogiri'
require 'active_support/core_ext/string/conversions.rb'



class ScraperUtils
  @@iso_6393_codes = File.open(File.expand_path("../lib/iso-639-3_Name_Index_20120816.tab", __FILE__), 'r').readlines
  @@iso_country_codes = Nokogiri::XML(open(File.expand_path("../lib/country_names_and_code_elements_xml.htm", __FILE__)))
  @@clean_iso_table = {}

  def initialize()
    @@iso_6393_codes.each do |line|
      line = line.split("\t")
      @@clean_iso_table[normalize(line[1])] = line[0].chomp
     
    end

  end

  #Levenshtein implementation courtesy of wikipedia
  def levenshtein(a, b)
    a.chomp
    b.chomp

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
    n_lang = normalize(language.chomp)

    if @@clean_iso_table.include?(n_lang)
      best_match = [@@clean_iso_table[n_lang], 0]
    #else
      #levenshtein takes forever
      ##@@clean_iso_table.keys.each do |iso_lang|
        #ldist = levenshtein(iso_lang, n_lang)

       #if ldist < best_match[1]
         # best_match = [iso_lang, ldist]
        #end
      #end
    end
    return best_match
  end

  #Function to return iso code for each country
  def get_iso_country(country)
    @@iso_country_codes.xpath("//ISO_3166-1_Entry").each do |code|
      if (country.upcase == code.xpath("ISO_3166-1_Country_name")[0].content)
        return code.xpath("ISO_3166-1_Alpha-2_Code_element")[0].content
      end
    end
    return "UNK"
  end


  #Helper function for cleaning up language data
  #returned items must be chomped
  def tokenize(language)
    #Scrubs out parentheticals
    return language.gsub(/\(|\)|\-/, " ").split(/\/|\&amp\;|,|\sand\s/)
  end

  #Helper function returning 
  def normalize(string)
    return string.mb_chars.normalize(:kd).downcase.gsub(/[^\x20 | ^\x61-\x7A]/,'').split.sort.join(" ").to_s
  end

  #Helper function to get delta time in seconds
  def get_time_diff(time)
    return (time*60*60*24).to_i
  end

end
