module Gluttonberg
  module Settings
    class Locales < Gluttonberg::Application
      include AdminController
      # provides :xml, :yaml, :js

      before :find_locale, :only => [:delete, :edit, :update, :destroy]
      
      def index
        @locales = Locale.all_for_user(session.user , :order => [:name.asc])
        display @locales
      end

      def new
        only_provides :html
        @locale   = Locale.new
        prepare_to_edit
        render
      end

      def edit
        only_provides :html
        prepare_to_edit
        render
      end

      def delete
        only_provides :html
        display_delete_confirmation(
          :title      => "Delete the “#{@locale.name}” locale?",
          :action     => slice_url(:locale, @locale),
          :return_url => slice_url(:locales)
        )
      end

      def create
        @locale = Locale.new(params["gluttonberg::locale"])
        @locale.user_id = session.user.id
        if @locale.save
          redirect slice_url(:locales)
        else
          prepare_to_edit
          render :new
        end
      end

      def update
       
        unless params["gluttonberg::locale"].has_key?('dialect_ids')
          # no dialect ids were supplied so need to delete all dialect associations
          @locale.clear_all_dialects
        end

        if @locale.update_attributes(params["gluttonberg::locale"]) || !@locale.dirty?
          redirect slice_url(:locales)
        else
          prepare_to_edit
          render :edit
        end
      end

      def destroy
       
        if @locale.destroy
          redirect slice_url(:locales)
        else
          raise BadRequest
        end
      end

      private

      # Grabs the various model collections we need when editing or updating a record
      def prepare_to_edit
        locale_opts = {:order => [:name.desc]}
        locale_opts[:id.not] = @locale.id unless @locale.new_record?
        @locales  = Locale.all_for_user(session.user, locale_opts)
        @dialects = Dialect.all_for_user(session.user)        
      end
      
     def find_locale
        @locale = Locale.get_for_user(session.user , params[:id])
        raise NotFound unless @locale
      end
      
    end
    
  end
end
