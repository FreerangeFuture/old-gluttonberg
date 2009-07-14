require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

given "a generic_setting exists" do
  GenericSetting.all.destroy!
  request(resource(:generic_settings), :method => "POST", 
    :params => { :generic_setting => { :id => nil }})
end

describe "resource(:generic_settings)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:generic_settings))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of generic_settings" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a generic_setting exists" do
    before(:each) do
      @response = request(resource(:generic_settings))
    end
    
    it "has a list of generic_settings" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      GenericSetting.all.destroy!
      @response = request(resource(:generic_settings), :method => "POST", 
        :params => { :generic_setting => { :id => nil }})
    end
    
    it "redirects to resource(:generic_settings)" do
      @response.should redirect_to(resource(GenericSetting.first), :message => {:notice => "generic_setting was successfully created"})
    end
    
  end
end

describe "resource(@generic_setting)" do 
  describe "a successful DELETE", :given => "a generic_setting exists" do
     before(:each) do
       @response = request(resource(GenericSetting.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:generic_settings))
     end

   end
end

describe "resource(:generic_settings, :new)" do
  before(:each) do
    @response = request(resource(:generic_settings, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@generic_setting, :edit)", :given => "a generic_setting exists" do
  before(:each) do
    @response = request(resource(GenericSetting.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@generic_setting)", :given => "a generic_setting exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(GenericSetting.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @generic_setting = GenericSetting.first
      @response = request(resource(@generic_setting), :method => "PUT", 
        :params => { :generic_setting => {:id => @generic_setting.id} })
    end
  
    it "redirect to the generic_setting show action" do
      @response.should redirect_to(resource(@generic_setting))
    end
  end
  
end

