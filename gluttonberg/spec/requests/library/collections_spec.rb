require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

module Gluttonberg
  Library::Collections.skip_before(:ensure_authenticated)
  
  Library.setup
  
  given "a collection exists" do
    AssetCollection.all.destroy!
    Asset.all.destroy!
    8.of { Asset.generate }
    AssetCollection.generate
  end
  
  describe "url(:gluttonberg_collections)" do
    describe "GET" do
      before(:each) do 
        AssetCollection.all.destroy!
        Asset.all.destroy!
        25.of { Asset.generate }
        10.of { AssetCollection.generate }
        @response = request(url(:gluttonberg_collections))
      end

      it "responds successfully" do
        @response.should be_successful
      end

      it "contains a list of collections" do
        @response.should have_selector("#wrapper table")
      end
    end

    describe "a successful POST" do
      before(:each) do
        AssetCollection.all.destroy!
        @response = request(url(:gluttonberg_collections), :method => "POST", 
          :params => { "gluttonberg::asset_collection" => {:name => "Press Shots"}})
      end

      it "redirects to url(:gluttonberg_library)" do
        @response.should redirect_to(url(:gluttonberg_library))
      end
    end
  end

  describe "url(:gluttonberg_collection, @collection)" do 
    describe "a successful DELETE", :given => "a collection exists" do
       before(:each) do
         @response = request(url(:gluttonberg_collection, AssetCollection.first), :method => "DELETE")
       end

       it "should redirect to url(:gluttonberg_library)" do
         @response.should redirect_to(url(:gluttonberg_librar))
       end
     end
  end

  describe "url(:new_gluttonberg_collection)" do
    before(:each) do
      @response = request(url(:new_gluttonberg_collection))
    end

    it "responds successfully" do
      @response.should be_successful
    end
  end

  describe "url(:edit_gluttonberg_collection, @collection)", :given => "a collection exists" do
    before(:each) do
      @response = request(url(:edit_gluttonberg_collection, AssetCollection.first))
    end

    it "responds successfully" do
      @response.should be_successful
    end
  end

  describe "url(:gluttonberg_collection, @collection)", :given => "a collection exists" do

    describe "PUT" do
      before(:each) do
        @collection = AssetCollection.first
        @response = request(url(:gluttonberg_collection, @collection), :method => "PUT", 
          :params => { "gluttonberg::asset_collection" => {:name => "Weppa!"} })
      end

      it "redirect to the library" do
        @response.should redirect_to(url(:gluttonberg_library))
      end
      
      it "should update the name of the model" do
        AssetCollection.first.name.should == "Weppa!"
      end
    end

  end
end
