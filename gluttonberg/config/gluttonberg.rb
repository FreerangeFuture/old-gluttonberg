Gluttonberg::Config.locales do
  locale :australia_english do
    location  :au, "Australia"
    dialect   :en, "English"
    default   true
  end

  locale :spain_spanish do
    location  :es, "Spain", "Espana"
    dialect   :es, "Spanish", "Espanol"
  end

  locale :spain_catalan do
    location  :es, "Spain", "Espana"
    dialect   :ca, "Catalan", "Catala"
  end
end

Gluttonberg::PageDescription.add do
  page :simple do
    label       "Simple"
    description "This page has sections, weeee!"
    
    section :main do
      label "Main Content"
      type  :rich_text_content
      limit 1..2
    end
    
    section :side do
      label "Sidebar"
      type  :rich_text_content
      limit 1
    end
  end
end
