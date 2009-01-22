require File.join( File.dirname(__FILE__), '..', '..', "spec_helper" )

module Gluttonberg
  describe Config::Locale do
    before :all do
      Gluttonberg::Config.locales do
        locale :australia_english do
          location  :au, "Australia"
          dialect   :en, "English"
          default   true
        end
        
        locale :usa_default do
          location  :us, "U.S.A."
        end

        locale :spain_spanish do
          location  :es, "Spain", "Espana"
          dialect   :es, "Spanish", "Espanol"
        end

        locale :spain_catalan do
          location  :es, "Spain", "Espana"
          dialect   :ca, "Catalan", "Catala"
        end
      end
    end
    
    it "should create locales" do
      Config::Locale.all.empty?.should be_false
    end

    it "should create four unique locales" do
      Config::Locale.all.length.should == 4
    end

    it "should set a default" do
      Config::Locale.default.should_not be_nil
      Config::Locale.default[:name].should == :australia_english
    end

    it "should get the correct location" do
      Config::Locale.get("au", "en")[:name].should == :australia_english
    end
    
    it "should return the correct locale when using bracket notation" do
      Config::Locale[:spain_catalan][:dialect][:code].should == "ca"
    end
    
    it "should set a default dialect" do
      Config::Locale[:usa_default][:dialect][:code].should == "en"
    end
    
  end
end
