migration 1, :move_to_page_dsl  do
  up do    
    adapter = DataMapper.repository
    
    Gluttonberg::Content.content_classes.each do |klass|
      klass.property(:page_section_id, Integer)
      klass.all.each do |content|
        conditions  = "SELECT name FROM gluttonberg_page_sections WHERE id = #{content.page_section_id}"
        section     = adapter.query(conditions)
        content.update_attributes(:section_name => section.first) unless section.empty?
      end
      # Only try to drop this column if this is something other than SQLite
      unless adapter.uri.scheme == "sqlite3"
        modify_table(klass.storage_name.to_sym) { drop_column(:page_section_id) }
      end
    end
    
    drop_table(:gluttonberg_page_types)
    drop_table(:gluttonberg_page_sections)
    drop_table(:gluttonberg_layouts)
  end

  down do
  end
end
