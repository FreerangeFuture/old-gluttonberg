module Gluttonberg
  module Library
    class Main < Gluttonberg::Application
      include Gluttonberg::AdminController
      
      def index
        # Get the latest assets, ensuring that we always grab at least 15 records
        range = ((Time.now - 24.hours)..Time.now)
        @assets = Asset.all(:updated_at => range, :order => [:updated_at.asc], :limit => 15)
        # Collections
        @collections = AssetCollection.all_for_user(session.user , :order => [:name.desc])
        @categories = AssetCategory.all
        render
      end
    end
  end
end