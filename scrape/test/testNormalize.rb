#Tests for our helper functions
require File.expand_path('../../normalize', __FILE__)
require 'rspec'

describe ".levenshtein" do
  before(:each) do
    @utils = ScraperUtils.new
  end

  it "returns 0 for matching strings" do
    @utils.levenshtein("a", "a").should eq(0)    
  end

  it "returns 1 for strings differing by 1 character" do
    @utils.levenshtein("a", "A").should eq(1)
  end

  it "ignores whitespace" do
    @utils.levenshtein("A ", "A").should eq(0)
  end

end
  
