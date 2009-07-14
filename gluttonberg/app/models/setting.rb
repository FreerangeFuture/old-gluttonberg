module Gluttonberg
  class Setting
    include DataMapper::Resource    
 #   include Gluttonberg::Authorizable
    
    property :id,               Serial 
    property :name,             String , :nullable => false
    property :value,            Text
    property :category,         DataMapper::Types::Enum[:meta_data, :website_info], :default => :meta_data
    property :row,              Integer
    property :delete_able,      Boolean, :default => true
        
    
    def self.generate_settings(settings={})      
      settings.each do |key , val |
        obj = self.new(:name=> key , :category => val[0] , :row => val[1] , :delete_able => false)
        obj.save!
      end  
    end  
    
    def self.generate_common_settings
      settings = {
        :title => [:meta_data , 0], 
        :description => [:meta_data, 2], 
        :keywords => [:meta_data, 1]
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
