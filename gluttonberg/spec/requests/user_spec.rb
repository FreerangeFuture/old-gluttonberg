require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "/user" do
  before(:each) do
    @response = request("/user")
  end
end