require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

module Gluttonberg
  Help.skip_before(:ensure_authenticated)
  
  describe 'url(:gluttonberg_help, :module_and_controller => "gluttonberg/content/pages", :page => "edit")' do
    before(:each) do
      @response = request(
        url(:gluttonberg_help, :module_and_controller => "gluttonberg/content/pages", :page => "edit"),
        "HTTP_X_REQUESTED_WITH" => "XMLHttpRequest"
      )
    end
    
    it "should render successfully" do
      @response.should be_successful
    end
    
    it "should contain the correct help file" do
      @response.should have_selector("h1:contains('Editing page settings')")
    end
  end
end
