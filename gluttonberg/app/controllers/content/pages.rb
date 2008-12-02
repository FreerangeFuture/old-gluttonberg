module Gluttonberg
  module Content
    class Pages < Gluttonberg::Application
      include Gluttonberg::AdminController

      before :find_page, :only => [:show, :edit, :delete, :update, :destroy]

      def index
        @pages = Page.all(:parent_id => nil, :order => [:position.asc])
        display @pages
      end

      def show
        @page = Page.get(params[:id])
        raise NotFound unless @page
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

      def move_page
        only_provides :json

        def source_in_destination_ancestry(source, destination)
          cur_page = destination
          if cur_page == source
            return true
          end
          while (cur_page.parent != source)
            cur_page = cur_page.parent
            return false if cur_page == nil
          end
          true
        end

        # "mode"=>"INSERT", "action"=>"move_page", "dest_page_id"=>"3", "source_page_id"=>"4"
        @pages = Page.all
        @mode = params[:mode]
        @source = Page.get(params[:source_page_id])
        @dest   = Page.get(params[:dest_page_id])

        if source_in_destination_ancestry(@source, @dest)
          raise BadRequest
        end

        if (@mode == 'INSERT') and @source and @dest
          # an insert is a reparenting operation. the source becomes the child of the
          # dest.
          @source.parent_id = @dest.id
          @source.move :highest
          JSON.pretty_generate({:success => true})
        else
          # if we are inserting after a node and that node has children, we are actually
          # reparenting to that node
          if (@mode == 'AFTER') and (@dest.children.count > 0)
            if (@source.parent_id != @dest.id)
              @source.parent_id = @dest.id
              @source.save!
            end
            @source.move :highest
            @source.save!
            JSON.pretty_generate({:success => true})
          else

            # if the pages don't have the same parent, need to reparent
            # the @source
            if @source.parent_id != @dest.parent_id
              @source.parent_id = @dest.parent_id
              @source.save!
            end

            if @mode == 'AFTER'
              @source.move :below => @dest
              @source.save!
              JSON.pretty_generate({:success => true})
            elsif @mode == 'BEFORE'
              @source.move :above => @dest
              @source.save!
              JSON.pretty_generate({:success => true})
            else
              raise BadRequest
            end
          end
        end
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
      
    end
  end
end 
