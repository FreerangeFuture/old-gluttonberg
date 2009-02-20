namespace :slices do
  namespace :gluttonberg do 
    desc "Set or reset the cached depths on pages"
    task :set_page_depths => :merb_env do
      pages = Gluttonberg::Page.all(:parent_id => nil)
      pages.each { |page| page.set_depth!(0) }
    end
  end
end