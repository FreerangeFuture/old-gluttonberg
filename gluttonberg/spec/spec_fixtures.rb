module Gluttonberg
  
  module Library
    Asset.fixture {{
      :name         => (1..3).of { /\w+/.gen }.join(" ").capitalize,
      :description  => (1..2).of { /[:paragraph:]/.generate }.join("\n\n"),
      :file         => Library.mock_tempfile
    }}
    
    FIXTURE_PATH = Gluttonberg.root / "spec" / "fixtures" / "assets"
    FIXTURE_FILES = [
      {:content_type => "image/jpg", :filename => "gluttonberg_logo.jpg"}
    ]
    
    def self.mock_tempfile
      file = FIXTURE_FILES.pick
      {
        :filename     => file[:filename],
        :content_type => file[:content_type],
        :size         => (300...8000).pick, 
        :tempfile     => temp_file(file[:filename])
      }
    end
    
    def self.temp_file(name)
      File.open(FIXTURE_PATH / name)
    end
  end
  
  Dialect.fixture {{
    :code => /\w{2}/.gen.downcase,
    :name => /\w+/.gen.capitalize
  }}

  Locale.fixture {{
    :name => /\w+/.gen.capitalize,
    :slug => /\w+/.gen,
    :dialects => (1..3).of { Dialect.generate }
  }}

  PageSection.fixture {{
    :name => (1..3).of { /\w+/.gen }.join(" ").capitalize,
    :name => /\w+/.gen,
    :type => "rich_texts"
  }}

  PageType.fixture {{
    :name     => (1..3).of { /\w+/.gen }.join(" ").capitalize,
    :filename => /\w+/.gen,
    :sections => (1..5).of { PageSection.generate }
  }}
  
  Layout.fixture {{
    :name     => (1..3).of { /\w+/.gen }.join(" ").capitalize,
    :filename => /\w+/.gen
  }}

  Page.fixture(:no_templates) {{
    :name     => (name = (1..3).of { /\w+/.gen }.join(" ")).capitalize,
    :slug     => name.downcase.gsub(" ", "_")
  }}

  Page.fixture(:parent) {{
    :name     => (name = /\w+/.gen),
    :slug     => name.downcase.gsub(" ", "_"),
    :type     => PageType.pick,
    :layout   => Layout.pick
  }}

  Page.fixture(:child) {{
    :parent     => Page.pick(:parent),
    :name       => (name = /\w+/.gen),
    :slug       => name.downcase.gsub(" ", "_"),
    :type     => PageType.pick,
    :layout   => Layout.pick
  }}

  PageLocalization.fixture {{
    :name => (name = (1..3).of { /\w+/.gen }).capitalize,
    :slug => name.downcase.gsub(" ", "_")
  }}
  
  User.fixture {{
    :name                   => (1..3).of { /\w+/.gen }.join(" ").capitalize,
    :email                  => /\w+@\w+\.com/.gen,
    :password               => "password",
    :password_confirmation  => "password"
  }}
  
end
