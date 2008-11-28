require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

module Gluttonberg
  Main.skip_before(:ensure_authenticated)
  
  describe "url(:gluttonberg_admin_root)" do
    before(:each) do
      @response = request(url(:gluttonberg_admin_root))
    end
    
    it "should render dashboard" do
      @response.should be_successful
    end
  end
end
