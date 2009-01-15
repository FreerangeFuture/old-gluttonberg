module Gluttonberg
  module Content
    class Pages < Gluttonberg::Application
      include Gluttonberg::AdminController

      drag_tree Page, :route_name => :page_move, :auto_gen_route => false

      before :find_page, :only => [:show, :edit, :delete, :update, :destroy]

      def index
        @pages = Page.all(:parent_id => nil, :order => [:position.asc])
        display @pages
      end

      def show
        display @page
      end

      def new
        only_provides :html
        @page = Page.new
        @page_localization = PageLocalization.new
        prepare_to_edit
        render
      end

      def edit
        only_provides :html
        prepare_to_edit
        render
      end

      def delete
        display_delete_confirmation(
          :title      => "Delete “#{@page.name}” page?",
          :action     => slice_url(:page, @page),
          :return_url => slice_url(:page, @page)
        )
      end

      def create
        @page = Page.new(params["gluttonberg::page"])
        if @page.save
          redirect slice_url(:page, @page)
        else
          prepare_to_edit
          render :new
        end
      end

      def update
        if @page.update_attributes(params["gluttonberg::page"]) || !@page.dirty?
          redirect slice_url(:page, @page)
        else
          raise BadRequest
        end
      end

      def destroy
        if @page.destroy
          redirect slice_url(:pages)
        else
          raise BadRequest
        end
      end

      private

      def prepare_to_edit
        @pages      = params[:id] ? Page.all(:id.not => params[:id]) : Page.all
        @dialects   = Dialect.all
        @types      = PageType.all
        @layouts    = Layout.all
        @locales    = Locale.all
      end

      def find_page
        @page = Page.get(params[:id])
        raise NotFound unless @page
      end
      
      # Returns a collection of Locale/Dialect pairs that have not yet been used
      # with the specified page.
      def pending_localizations
        existing = @page.localizations.collect {|l| [l.locale_id, l.dialect_id]}
        pending = []
        dialects = Dialect.all
        Locale.all.each do |locale|
          dialects.each do |dialect|
            unless existing.include?([locale.id, dialect.id])
              pending << ["#{locale.id}-#{dialect.id}", "#{locale.name} - #{dialect.name}"]
            end
          end
        end
        pending
      end
    end
  end
end 
