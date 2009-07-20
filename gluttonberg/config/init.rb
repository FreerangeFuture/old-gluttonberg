$KCODE = 'UTF8'

require 'dm-core'
dependency "merb-assets"

use_orm :datamapper
use_test :rspec
use_template_engine :haml

Merb::Config.use do |c|  
  c[:session_id_key] = 'saywhat'
  c[:session_secret_key]  = 'cbdf5572c84cd403a94c32a68e50775f786c4f59'
  c[:session_store] = 'cookie'
end

#DataObjects::Sqlite3.logger = DataMapper::Logger.new(STDOUT, :debug)

Merb::BootLoader.before_app_loads do
  Merb::Controller.send(:include, Merb::AssetsMixin)  
end

Merb::BootLoader.after_app_loads do
  #Gluttonberg::Components.register(:thing, :label => "Thing")
  begin
    settings = Gluttonberg::Setting.all(:enabled => true)
    settings.each do |setting|
      Merb::Slices::config[:gluttonberg][setting.name.to_sym] = setting.value
    end
  rescue
  end  
end
