#!/bin/ruby
# -*- coding: utf-8 -*-

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


  #Function to return iso code for each language
  def get_iso_lang(language)
    best_match = ["ZXX", language.length]
    n_lang = normalize(language.chomp)

    if @@clean_iso_table.include?(n_lang)
      best_match = [@@clean_iso_table[n_lang], 0]

    #Hard Codes to match ISO conventions to SCOLA conventions
    elsif n_lang == "mandarin"
      best_match = ["cmn", 0]
    elsif n_lang == "farsi"
      best_match = ["fas", 0]
    elsif n_lang == "swahili"
      best_match= ["swa", 0]
    elsif n_lang == "southern vietnamese"
      best_match = ["vie", 0]
    elsif n_lang == "malay"
      best_match = ["zlm", 0]
    elsif n_lang == "greek"
      best_match = ["ell", 0]
    elsif n_lang == "nepali"
      best_match = ["npi", 0]
    elsif n_lang == "iraqi"
      best_match = ["acm", 0]
    elsif n_lang == "ilocando"
      best_match = ["ilo", 0]
    elsif n_lang == "saraiki"
      best_match = ["skr", 0]
    elsif n_lang == "sorani"
      best_match = ["ckb", 0]
    elsif n_lang == "yakutian"
      best_match = ["sah", 0]
    elsif n_lang == "luganda"
      best_match = ["lug", 0]      
    elsif n_lang == "arabic yemeni"
      best_match = ["ara", 0]

    end

    return best_match
  end

  #Function to return iso code for each country
  def get_iso_country(country)
    #Kinda redundant but downcasing first makes the hardcoding a bit more obvious
    country = country.downcase

    if country == "bosnia-herzogovnia"
      country = "bosnia and herzogovnia"
    elsif country == "russia"
      country = "russian federation"
    elsif country == "laos"
      country = "lao peoples democratic republic"
    elsif country == "iran"
      country = "islamic republic of iran"
    elsif country == "taiwan"
      country = "province of china taiwan"
    elsif country == "north korea"
      country = "democratic people's republic of korea"
    elsif country == "south korea"
      country = "republic of korea"
    elsif country == "basque spain"
      country = "spain"
    elsif country == "macedonia"
      country = "the former yugoslav republic of macedonia"
    elsif country == "tanzania"
      country = "united republic of tanzania"
    elsif country == "vietnam"
      country = "viet nam"
    elsif country == "venezuela"
      country = "bolivarian republic of venezuela"
    elsif country == "syria"
      country = "syrian arab republic"
    elsif country == "rep.dem.congo"
      country = "congo"
    elsif country == "dagestan"
      country = "russian federation"
    elsif country == "adygea"
      country = "russian federation"
    elsif country == "karachaevo circassia"
      country = "russian federation"
    elsif country == "tartarstan"
      country = "russian federation"
    elsif country == "ivory coast"
      # This seems like the wrong way of doing this but not sure how else to guarentee the match
      country = "CÃTE D'IVOIRE".downcase
    end

    country = normalize(country)
    
    @@iso_country_codes.xpath("//ISO_3166-1_Entry").each do |code|
      n_country = normalize(code.xpath("ISO_3166-1_Country_name")[0].content)

      if (country.upcase == n_country.upcase)
        return code.xpath("ISO_3166-1_Alpha-2_Code_element")[0].content
      end
    end
    return "ZZ"
  end


  # Helper function for cleaning up language data
  # items are returned as a list and individual items must be chomped if necessary
  # the way this split is implemented is highly dependent on SCOLA.orgs conventions
  # and could easily be broken if they decided to change those
  def tokenize(language)
    #Scrubs out parentheticals
    return language.gsub(/\(|\)|\-/, " ").split(/\/|\&amp\;|\&|,|\sand\s/)
  end

  #Helper function returning a string kd normalized but allowing spaces, basically removes all accents
  def normalize(string)
    return string.mb_chars.normalize(:kd).downcase.gsub(/[^\x20 | ^\x61-\x7A]/,'').split.sort.join(" ").to_s
  end

  #Helper function to get delta time in seconds
  def get_time_diff(time)
    return (time*60*60*24).to_i
  end

end
