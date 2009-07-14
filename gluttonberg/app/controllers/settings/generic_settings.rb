module Gluttonberg
  module Settings
    class GenericSettings < Application
      # provides :xml, :yaml, :js
      include AdminController
    
      def index
        @settings = Setting.all(:order => [:row.asc])
        display @settings
      end
              
      def new
        only_provides :html
        @setting = Setting.new
        display @setting
      end
    
      def edit
        only_provides :html
        @setting = Setting.get(params[:id])
        raise NotFound unless @setting
        display @setting
      end
    
      def create
        @setting = Setting.new(params["gluttonberg::setting"])
        count = Setting.all.length
        @setting.row = count + 1
        if @setting.save!
          redirect slice_url(:gluttonberg, :generic_settings)
        else
          message[:error] = "Setting failed to be created"
          render :new
        end
      end
    
      def update
        @setting = Setting.get(params[:id])
        raise NotFound unless @setting
        if @setting.update_attributes(params["gluttonberg::setting"])
          redirect slice_url(:gluttonberg, :generic_settings)
        else
          display @setting, :edit
        end
      end
      
      def delete
        @setting = Setting.get(params[:id])
        display_delete_confirmation(
          :title      => "Delete “#{@setting.name}” setting?",
          :action     => slice_url(:gluttonberg, :generic_setting, @setting),
          :return_url => slice_url(:gluttonberg, :generic_settings)
        )
      end
    
      def destroy
        @setting = Setting.get(params[:id])
        raise NotFound unless @setting
        if @setting.destroy
          redirect slice_url(:gluttonberg, :generic_settings)
        else
          raise InternalServerError
        end
      end
    
    end # GenericSettings
  end # Settings
end # Gluttonberg