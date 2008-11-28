require File.join( File.dirname(__FILE__), '..', "spec_helper" )

module Gluttonberg
  
  Library.setup
  
  describe Library do
    it "should have asset root set" do
      Library.root.should == Merb.dir_for(:public) / "assets"
    end
  end
end