require File.join( File.dirname(__FILE__), '..', '..', "spec_helper" )

module Gluttonberg
  describe Content::Localization do
    before :all do
      class NonLocalized
        include DataMapper::Resource
        include Content::Localization
        
        property :id, Serial
      end
      
      class StaffProfile
        include DataMapper::Resource
        include Content::Localization
        
        property :id,   Serial
        property :name, String
        
        is_localized do
          property :title,      String
          property :biography,  Text
        end
      end
      
      # Upgrade em
      StaffProfile.auto_upgrade!
      
      # Generate some dummy records
      shared = {:title => /\w+{2}/.gen.capitalize, :biography  => (1..2).of { /[:paragraph:]/.generate }.join("\n\n")}
      StaffProfileLocalization.fixture(:one) { {:dialect_id => 1, :locale_id => 1}.merge!(shared) }
      StaffProfileLocalization.fixture(:two) { {:dialect_id => 1, :locale_id => 2}.merge!(shared) }
      StaffProfile.fixture { {:name => /\w+{2}/.gen.capitalize} }
      
      10.of { 
        profile = StaffProfile.generate 
        StaffProfileLocalization.generate(:one, :parent => profile)
        StaffProfileLocalization.generate(:two, :parent => profile)
      }
    end
    
    it "should have a localization" do
      StaffProfile.localized_model.should_not be_nil
    end
    
    it "should correctly indicate the presence of a localization" do
      StaffProfile.localized?.should be_true
      NonLocalized.localized?.should be_false
    end
    
    it "should set the correct table name for the localization" do
      StaffProfile.localized_model.storage_name.should == "gluttonberg_staff_profile_localizations"
    end
    
    it "should generate the correct localized class name" do
      StaffProfile.localized_model.name.should == "Gluttonberg::StaffProfileLocalization"
    end
    
    it "should generate properties for the localization" do
      StaffProfile.localized_model.properties[:id].should_not be_nil
      StaffProfile.localized_model.properties[:created_at].should_not be_nil
      StaffProfile.localized_model.properties[:updated_at].should_not be_nil
    end
    
    it "should associate the localization to the dialect and locale" do
      StaffProfile.localized_model.relationships[:dialect].should_not be_nil
      StaffProfile.localized_model.relationships[:locale].should_not be_nil
    end
    
    it "should associate the model to it's localizations" do
      StaffProfile.relationships[:localizations].should_not be_nil
    end
    
    it "should associate the localization to it's model" do
      StaffProfile.localized_model.relationships[:parent].should_not be_nil
    end
    
    it "should return a model with the correct localization" do
      model = StaffProfile.first_with_localization(:dialect => 1, :locale => 1)
      model.should_not be_nil
      model.current_localization.dialect_id.should == 1
      model.current_localization.locale_id.should == 1
    end
    
    it "should return a collection of models with the correct localizations" do
      collection = StaffProfile.all_with_localization(:dialect => 1, :locale => 1)
      collection.each do |model|
        model.should_not be_nil
        model.current_localization.dialect_id.should == 1
        model.current_localization.locale_id.should == 1
      end
    end
  end
end
