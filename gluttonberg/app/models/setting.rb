module Gluttonberg
  class Setting
    include DataMapper::Resource    
 #   include Gluttonberg::Authorizable
    
    property :id,               Serial 
    property :name,             String , :nullable => false
    property :value,            Text
    property :category,         DataMapper::Types::Enum[:meta_data, :website_info, :google_analytics], :default => :meta_data
    property :row,              Integer
    property :delete_able,      Boolean, :default => true
    property :enabled,          Boolean, :default => true
    property :help,             Text
    
    def self.generate_settings(settings={})      
      settings.each do |key , val |
        obj = self.new(:name=> key , :category => val[0] , :row => val[1] , :delete_able => false , :help => val[2])
        obj.save!
      end  
    end  
    
    def self.generate_common_settings
      settings = {
        :title => [:meta_data , 0, "Website Title"], 
        :description => [:meta_data, 2 , "The Description will appear in search engine's result list."], 
        :keywords => [:meta_data, 1, "Please separate keywords with a comma."],
        :google_analytics => [:google_analytics, 3, "Google Analytics ID"]
      }
      self.generate_settings(settings)
    end  
    
    def self.update_settings(settings={})
      settings.each do |key , val |
        obj = self.first(:name=> key)
        obj.value = val
        obj.save!
      end  
    end  

  end
end
