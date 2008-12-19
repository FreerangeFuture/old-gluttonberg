require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a asset_category exists" do
  AssetCategory.all.destroy!
  request(resource(:asset_categories), :method => "POST", 
    :params => { :asset_category => { :id => nil }})
end

describe "resource(:asset_categories)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:asset_categories))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of asset_categories" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a asset_category exists" do
    before(:each) do
      @response = request(resource(:asset_categories))
    end
    
    it "has a list of asset_categories" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      AssetCategory.all.destroy!
      @response = request(resource(:asset_categories), :method => "POST", 
        :params => { :asset_category => { :id => nil }})
    end
    
    it "redirects to resource(:asset_categories)" do
      @response.should redirect_to(resource(AssetCategory.first), :message => {:notice => "asset_category was successfully created"})
    end
    
  end
end

describe "resource(@asset_category)" do 
  describe "a successful DELETE", :given => "a asset_category exists" do
     before(:each) do
       @response = request(resource(AssetCategory.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:asset_categories))
     end

   end
end

describe "resource(:asset_categories, :new)" do
  before(:each) do
    @response = request(resource(:asset_categories, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@asset_category, :edit)", :given => "a asset_category exists" do
  before(:each) do
    @response = request(resource(AssetCategory.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@asset_category)", :given => "a asset_category exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(AssetCategory.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @asset_category = AssetCategory.first
      @response = request(resource(@asset_category), :method => "PUT", 
        :params => { :asset_category => {:id => @asset_category.id} })
    end
  
    it "redirect to the article show action" do
      @response.should redirect_to(resource(@asset_category))
    end
  end
  
end

