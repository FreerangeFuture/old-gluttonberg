module Gluttonberg
  class PageObserver
    include DataMapper::Observer

    observe Page

    # Generate a series of content models for this page based on the specified
    # template. These models will be empty, but ready to be displayed in the 
    # admin interface for editing.
    after :create do      
      Merb.logger.info("Generating page localizations")
      Locale.all.each do |locale|
        locale.dialects.all.each do |dialect|
          loc = localizations.create(
            :name     => name,
            :dialect  => dialect,
            :locale   => locale
          )
        end
      end
        
      unless description.sections.empty?
        Merb.logger.info("Generating stubbed content for new page")
        description.sections.each do |name, section|
          # Create the content
          association = send(section[:type].to_s.pluralize)
          content = association.create(:section_name => name)
          # Create each localization
#          if content.model.localized?
#            localizations.all.each do |localization|
#              content.localizations.create(:parent => content, :page_localization => localization)
#            end
#          end
        end
      end
      
    end
    
    
    before :update do
      # This checks to make see if we need to regenerate paths for child-pages
      # and adds a flag if it does.
      if attribute_dirty?(:parent_id) || attribute_dirty?(:slug)
        @paths_need_recaching = true
      end
    end
    
    before :save do
      # We also need to check if the depths need to be recalculated for this
      # page and for it's children
      if attribute_dirty?(:parent_id) || new_record?
        if parent_id
          set_depth(parent.depth + 1)
        else
          set_depth(0)
        end
      end
    end

    after :update do
    
      # This has the page localizations regenerate their path if the slug or 
      # parent for this page has changed.
      if paths_need_recaching?
        localizations.each { |l| l.regenerate_path! }
      end
      
      # Set off some code which causes a recursion through all the child pages
      # and updates their depth
      if @depths_need_recaching
        children.each { |c| c.set_depth!(depth + 1) }
      end
    end
    
    # A dirty hack to remove the page localizations after a page is destroyed.
    # This is in lieu of a :dependent option in DM associations
    after :destroy do
      page_localizations = PageLocalization.all(:page_id => id)
      page_localization_ids = page_localizations.collect { |l| l.id }
      # Destroy the localizations first, then the main content record
      Gluttonberg::Content.content_classes.each do |klass|
        if klass.localized?
          klass.localizations.model.all(:page_localization_id => page_localization_ids).destroy!
        end
        klass.all(:page_id => id).destroy!
      end
      page_localizations.destroy!
    end
  end
end