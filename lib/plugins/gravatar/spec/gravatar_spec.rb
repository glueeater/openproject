#-- encoding: UTF-8
require 'rubygems'
require 'erb'  # to get "h"
require 'active_support'  # to get "returning"
require File.dirname(__FILE__) + '/../lib/gravatar'
include GravatarHelper, GravatarHelper::PublicMethods, ERB::Util

describe "gravatar_url with a custom default URL" do
  before(:each) do
    @original_options = DEFAULT_OPTIONS.dup
    DEFAULT_OPTIONS[:default] = "no_avatar.png"
    @url = gravatar_url("somewhere")
  end

  it "should include the \"default\" argument in the result" do
    expect(@url).to match(/&default=no_avatar.png/)
  end

  after(:each) do
    DEFAULT_OPTIONS.merge!(@original_options)
  end

end

describe "gravatar_url with default settings" do
  before(:each) do
    @url = gravatar_url("somewhere")
  end

  it "should have a nil default URL" do
    expect(DEFAULT_OPTIONS[:default]).to be_nil
  end

  it "should not include the \"default\" argument in the result" do
    expect(@url).not_to match(/&default=/)
  end

end

describe "gravatar with a custom title option" do
  it "should include the title in the result" do
    expect(gravatar('example@example.com', :title => "This is a title attribute")).to match(/This is a title attribute/)
  end
end
