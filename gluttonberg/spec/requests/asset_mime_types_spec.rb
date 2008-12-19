require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a asset_mime_type exists" do
  AssetMimeType.all.destroy!
  request(resource(:asset_mime_types), :method => "POST", 
    :params => { :asset_mime_type => { :id => nil }})
end

describe "resource(:asset_mime_types)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:asset_mime_types))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of asset_mime_types" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a asset_mime_type exists" do
    before(:each) do
      @response = request(resource(:asset_mime_types))
    end
    
    it "has a list of asset_mime_types" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      AssetMimeType.all.destroy!
      @response = request(resource(:asset_mime_types), :method => "POST", 
        :params => { :asset_mime_type => { :id => nil }})
    end
    
    it "redirects to resource(:asset_mime_types)" do
      @response.should redirect_to(resource(AssetMimeType.first), :message => {:notice => "asset_mime_type was successfully created"})
    end
    
  end
end

describe "resource(@asset_mime_type)" do 
  describe "a successful DELETE", :given => "a asset_mime_type exists" do
     before(:each) do
       @response = request(resource(AssetMimeType.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:asset_mime_types))
     end

   end
end

describe "resource(:asset_mime_types, :new)" do
  before(:each) do
    @response = request(resource(:asset_mime_types, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@asset_mime_type, :edit)", :given => "a asset_mime_type exists" do
  before(:each) do
    @response = request(resource(AssetMimeType.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@asset_mime_type)", :given => "a asset_mime_type exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(AssetMimeType.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @asset_mime_type = AssetMimeType.first
      @response = request(resource(@asset_mime_type), :method => "PUT", 
        :params => { :asset_mime_type => {:id => @asset_mime_type.id} })
    end
  
    it "redirect to the article show action" do
      @response.should redirect_to(resource(@asset_mime_type))
    end
  end
  
end

