#Tests for our helper functions
require 'normalize'

describe ScraperUtils, "#levenshtein" do
  it "returns 0 for matching strings" do
    utils = ScraperUtils.new
    utils.levenshtein("a", "a").should eq(0)
  end
end
  
