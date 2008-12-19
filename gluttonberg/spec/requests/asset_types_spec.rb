require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a asset_type exists" do
  AssetType.all.destroy!
  request(resource(:asset_types), :method => "POST", 
    :params => { :asset_type => { :id => nil }})
end

describe "resource(:asset_types)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:asset_types))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of asset_types" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a asset_type exists" do
    before(:each) do
      @response = request(resource(:asset_types))
    end
    
    it "has a list of asset_types" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      AssetType.all.destroy!
      @response = request(resource(:asset_types), :method => "POST", 
        :params => { :asset_type => { :id => nil }})
    end
    
    it "redirects to resource(:asset_types)" do
      @response.should redirect_to(resource(AssetType.first), :message => {:notice => "asset_type was successfully created"})
    end
    
  end
end

describe "resource(@asset_type)" do 
  describe "a successful DELETE", :given => "a asset_type exists" do
     before(:each) do
       @response = request(resource(AssetType.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:asset_types))
     end

   end
end

describe "resource(:asset_types, :new)" do
  before(:each) do
    @response = request(resource(:asset_types, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@asset_type, :edit)", :given => "a asset_type exists" do
  before(:each) do
    @response = request(resource(AssetType.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@asset_type)", :given => "a asset_type exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(AssetType.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @asset_type = AssetType.first
      @response = request(resource(@asset_type), :method => "PUT", 
        :params => { :asset_type => {:id => @asset_type.id} })
    end
  
    it "redirect to the article show action" do
      @response.should redirect_to(resource(@asset_type))
    end
  end
  
end

