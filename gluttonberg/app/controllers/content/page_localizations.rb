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
        unless @page_localization.contents.blank?       
	        unless @page_localization.update_attributes(params["gluttonberg::page_localization"]) && !@page_localization.dirty?	          
	          render :edit
	        end              
        else      
      	
      	  @page_localization.empty_contents.each do |content|      	
      		 name = Extlib::Inflection.underscore(content.class.to_s.split("::")[1]).pluralize
	      	val = params["gluttonberg::page_localization"]["contents"][name][content.id.to_s]["text"]
	      	if content.model.localized?                  	
	              content.localizations.create(:parent => content, :page_localization => @page_localization , :text=>val)            
	         end
          end  
        end	
      
        redirect slice_url(:page, params[:page_id])        
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
