require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

module Gluttonberg
  Library::Assets.skip_before(:ensure_authenticated)
  Library.setup
  
  given "a asset exists" do
    Asset.all.destroy!
    Asset.generate
  end
  
  describe "url(:gluttonberg_assets)" do
    describe "GET" do
      before(:each) do 
        Asset.all.destroy!
      end
      
      describe "url(:gluttonberg_assets)" do
        before(:each) do
          10.of { Asset.generate }
          @response = request(url(:gluttonberg_assets))
        end
        
        it "index should redirect" do
          @response.should redirect_to(url(:gluttonberg_asset_category, :category => "all"))
        end
      end
      
      describe "url(:gluttonberg_asset_category, :category => @category)" do
        before(:each) do
          Asset.generate(:type => "document")
          @response = request(url(:gluttonberg_asset_category, :category => "document"))
        end
        
        it "category should be successful" do
          @response.should be_successful
        end

        it "category should have assets" do
          @response.should be_successful
        end
      end
    end

    describe "a successful POST" do
      before(:each) do
        Asset.all.destroy!
        3.of { Dialect.generate }
        @response = request(url(:gluttonberg_assets), :method => "POST", 
          :params => { "gluttonberg::asset" => {
            :name         => "Somefing",
            :description  => "This is my asset",
            :file         => Library.temp_file("gluttonberg_logo.jpg")
        }})
      end

      it "redirects to url(:gluttonberg_assets)" do
        pending
        @response.should redirect_to(url(:gluttonberg_assets))
      end
      
      it "should add asset" do
        pending
        Asset.first.should_not be_nil
      end
    end
  end

  describe "url(:gluttonberg_asset, @asset)" do 
    describe "a successful DELETE", :given => "a asset exists" do
       before(:each) do
         @response = request(url(:gluttonberg_asset, Asset.first), :method => "DELETE")
       end

       it "should redirect to the index action" do
         @response.should redirect_to(url(:gluttonberg_library))
       end
     end
  end

  describe "url(:new_gluttonberg_asset)" do
    before(:each) do
      @response = request(url(:new_gluttonberg_asset))
    end

    it "responds successfully" do
      @response.should be_successful
    end
    
    it "should contain a form" do
      @response.should have_selector("#wrapper form")
    end
  end

  describe "url(:edit_gluttonberg_asset, @asset)", :given => "a asset exists" do
    before(:each) do
      @response = request(url(:edit_gluttonberg_asset, Asset.first))
    end

    it "responds successfully" do
      @response.should be_successful
    end
  end

  describe "url(:gluttonberg_asset, @asset)", :given => "a asset exists" do

    describe "PUT" do
      before(:each) do
        @response = request(url(:gluttonberg_asset, Asset.first), :method => "PUT", 
          :params => { "gluttonberg::asset" => {:name => "Weppa!"} })
      end

      it "redirect to the show action" do
        @response.should redirect_to(url(:gluttonberg_asset, Asset.first))
      end
      
      it "should update the name of the model" do
        Asset.first.name.should == "Weppa!"
      end
    end

  end
end
