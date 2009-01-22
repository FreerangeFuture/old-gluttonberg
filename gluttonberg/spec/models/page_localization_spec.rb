require File.join( File.dirname(__FILE__), '..', "spec_helper" )

module Gluttonberg
  describe PageLocalization do
    before :all do
      Config.locales do
        locale :australia_english do
          location  :au, "Australia"
          dialect   :en, "English"
        end
        
        locale :new_zealand_english do
          location  :nz, "Australia"
          dialect   :en, "English"
        end
      end
      
      Config::Locale.all.each do |name, locale|
        instance_variable_set("@#{name}", PageLocalization.generate(:locale_name => name))
      end
    end
    
    it "should have the correct locale" do
      @new_zealand_english.locale.should == Config::Locale[:new_zealand_english]
    end
    
    it "should return correct name and code" do
      @australia_english.name_and_code.should == "#{@australia_english.name} (Australia/en)"
    end

    it "should return it's contents"
    it "should update it's associated contents"
    it "should set it's slug"
    it "should regenerate it's path"

  end 
end

