module Gluttonberg
  module Content
    class PageLocalizations < Gluttonberg::Application
      include Gluttonberg::AdminController
      
      before :find_localization, :exclude => [:index, :new, :create]
      
      def index
        @page_localizations = PageLocalization.all
        display @page_localizations
      end

      def new
        only_provides :html
        @page_localization = PageLocalization.new
        @page = Page.get(params[:page_id])
        render
      end

      def edit
        only_provides :html
        if @page_localization.contents.blank?
          @page_localization.generate_empty_contents           
        end
        render
      end

      def create
        @page_localization.page = Page.get(params[:page_id])
        if @page_localization.save
          redirect slice_url(:page, params[:page_id])
        else
          render :new
        end
      end

      def update
      #if localization record alread exist then update its content
        error_flag  = false
        unless @page_localization.contents.blank?       
	        unless @page_localization.update_attributes(params["gluttonberg::page_localization"]) && !@page_localization.dirty?	          
	          error_flag = true;
	        end              
        else #if localization content records does not exist then create new record here
      	        error_flag = @page_localization.save_contents params                  
        end	
         if error_flag
            render :edit 
         else   
          redirect slice_url(:page, params[:page_id])        
         end
       
      end

      def destroy
        if @page_localization.destroy
          redirect slice_url(:page_localization)
        else
          raise BadRequest
        end
      end

      private

      def find_localization
        @page_localization = PageLocalization.get(params[:id])
        raise NotFound unless @page_localization
      end
      
    end
  end  
end
