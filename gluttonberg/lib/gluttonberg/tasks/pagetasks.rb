namespace :slices do
  namespace :gluttonberg do 
    desc "Set or reset the cached depths on pages"
    task :set_page_depths => :merb_env do
      pages = Gluttonberg::Page.all(:parent_id => nil)
      pages.each { |page| page.set_depth!(0) }
    end
    
    desc "Convert all existing RichTextContent into HtmlContent"
    task :convert_rich_text_into_html_contents => :merb_env do
      Gluttonberg::RichTextContent.convert_to_html_content
    end
    
  end
end