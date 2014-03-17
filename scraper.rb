#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'

def fetch_web_content
  url = "http://kenpom.com/index.php?y=2014"

  return Nokogiri::HTML(open(url))
end

def extract_team_ratings(doc)
  ratings = {}
  doc.css("#ratings-table tbody tr").each do |row|
    #puts "row.children.length: #{row.children.length}"
    next if row.children.length < 7
    school = row.children[1].content
    pyth = row.children[4].content
    
    puts "school: #{school}"
    puts "pyth: #{pyth}"

    school.gsub!(/\d+$/, "")

    next if pyth == "Pyth"

    ratings[school] = pyth
  end

  return ratings
end

def write_ratings(ratings)
  File.open("ratings.tsv", 'w') do |f|
    ratings.each { |s, p| f.write(s + "\t" + p + "\n") }
  end
end

doc = fetch_web_content()
ratings = extract_team_ratings(doc)
write_ratings(ratings)
