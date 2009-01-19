module Gluttonberg
  module Templates
    def self.setup
      dir = Gluttonberg.config[:template_dir]
      unless File.exists?(dir)
        FileUtils.mkdir(dir)
        %w(layout pages editors).each {|d| FileUtils.mkdir(dir / d)}
      end
    end
    
    def self.root
      Gluttonberg.config[:template_dir]
    end
    
    def self.path_for(type)
      self.root / type
    end
    
    # Returns a specific template, or alternately returns a default.
    def self.template_for(template_type, filename, opts = {})
      # A bunch of potential matches in order of preference.
      candidates = if Gluttonberg.localized?
        # Locale and dialect
        # Locale only
        # Default
        [
          "#{filename}.#{opts[:locale].slug}.#{opts[:dialect].code}",
          "#{filename}.#{opts[:locale].slug}",
          "#{filename}"
        ]
      elsif Gluttonberg.translated?
        # Dialect
        # Default
        [
          "#{filename}.#{opts[:dialect].code}",
          "#{filename}"
        ]
      else
        [filename]
      end
      # Loop through them and return the first match
      for candidate in candidates 
        path = path_for(template_type) / candidate + ".*"
        matches = Dir.glob(path)
        return candidate unless matches.empty?
      end
      # This nil has to be here, otherwise the last evaluated object is 
      # returned, in this case the candidates hash.
      nil
    end
  end
end
