require 'merb-auth-more/mixins/salted_user'

module Gluttonberg
  class User
    include DataMapper::Resource
    include Merb::Authentication::Mixins::SaltedUser
    
    property :id, Serial
    property :name, String, :length => 1..100
    property :email, String, :length => 1..100
    property :is_super_admin, Boolean,  :default => true
    
    has n,      :assets,         :class_name => "Gluttonberg::Asset"
    has n,      :asset_collections,         :class_name => "Gluttonberg::AssetCollection"
    has n,      :asset_localizations,         :class_name => "Gluttonberg::AssetLocalization"
    
    def self.all_admin_users
      all( :is_super_admin => true )
    end
    
    def self.all_non_admin_users
      all( :is_super_admin => false )
    end
    
    def self.all_for_user(user , options = {})
        if user.is_super_admin
            all(options)
        else
            options[:id] = user.id
            all(options)
        end
    end
    
    def self.get_for_user(user , id)          
        found_user = nil          
        if user.is_super_admin            
            found_user = get(id)
        else
            found_user = user  if user.id.to_s == id.to_s               
        end
          found_user
    end  
    
  end
end
