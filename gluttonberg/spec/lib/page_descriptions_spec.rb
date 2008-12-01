require File.join( File.dirname(__FILE__), '..', "spec_helper" )

module Gluttonberg
  describe PageDescriptions do
    describe "Standard page with defaults" do
      before(:all) do
        PageDescriptions.describe do
          page :home do
            label "Homepage"
          end
        end
      end
      
      it "should store description" do
        PageDescriptions[:home].should_not be_nil
      end
      
      it "should set label" do
        PageDescriptions[:home][:label].should == "Homepage"
      end
      
      it "should have a default limit" do
        PageDescriptions[:home][:limit].should == :infinite
      end
      
      it "should have default template" do
        PageDescriptions[:home][:template].should_not be_nil
      end
      
      it "should have default layout" do
        PageDescriptions[:home][:layout].should_not be_nil
      end
    end
    
    describe "All the standard options" do
      before(:all) do
        PageDescriptions.describe do
          page :all do
            label "About us"
            template "about"
            layout "special"
            limit 3
          end
        end
        @desc = PageDescriptions[:all]
      end
      
      it "should have label" do
        @desc[:label].should == "About us"
      end
      
      it "should have correct template" do
        @desc[:template].should == "about"
      end
      
      it "should have correct layout" do
        @desc[:layout].should == "special"
      end
      
      it "should have correct limit" do
        @desc[:limit].should == 3
      end
    end
    
    describe "Sections should be defined correctly" do
      before(:all) do
        PageDescriptions.describe do
          page :sectioned do
            label "Has many sections"
            
            section :simple, 
              :label    => "Main", 
              :desc     => "Where you put the news ain't it.", 
              :content  => :rich_text_content
              
            section :complex, 
              :label    => "Favourite images", 
              :desc     => "The latest pictures that you like the most.", 
              :content  => :image_content,
              :count    => (2..6),
              :order_by => :position,
              :size     => ["100x200", :thumbnail],
              :kind     => [:gif, :jpg, :png]
          end
        end
        @desc = PageDescriptions[:sectioned]
      end
      
      it "should have sections defined" do
        @desc.sections.length.should == 2
      end
      
      it "should have base options" do
        @desc.sections[:complex].options.length.should == 4
        @desc.sections[:complex][:label].should == "Favourite images"
        @desc.sections[:complex][:desc].should == "The latest pictures that you like the most."
        @desc.sections[:complex][:content].should == :image_content
        @desc.sections[:complex][:count].should == (2..6)
      end
      
      it "should have additional options" do
        @desc.sections[:complex].content_options.length.should == 3
      end
    end
    
    describe "Rewrite" do
      
    end
  end
end
