require 'spec_helper'

describe 'login page' do
  #it 'prompts for name/passwd' do
  # :js => true enables selenium
  it 'prompts for name/passwd', :js => true do
    visit 'https://accounts.google.com/ServiceLogin?hl=en'
    page.should have_button('Sign in')
    page.should have_field('Email')
    page.should have_field('Password')
  end
end
