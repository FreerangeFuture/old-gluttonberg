require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

module Gluttonberg
  Settings::Locales.skip_before(:ensure_authenticated)
  
  given "a locale exists" do
    Locale.all.destroy!
    Dialect.all.destroy!
    Locale.generate
  end
  
  describe "url(:gluttonberg_locales)" do
    describe "GET" do
      before(:each) do 
        Locale.all.destroy!
        Dialect.all.destroy!
        10.of { Locale.generate }
        @response = request(url(:gluttonberg_locales))
      end

      it "responds successfully" do
        @response.should be_successful
      end

      it "contains a list of locales" do
        @response.should have_selector("#wrapper table")
      end
    end

    describe "a successful POST" do
      before(:each) do
        Locale.all.destroy!
        3.of { Dialect.generate }
        @dialect = Dialect.first
        @response = request(url(:gluttonberg_locales), :method => "POST", 
          :params => { "gluttonberg::locale" => {
            :name         => "Australia",
            :slug         => "au",
            :dialect_ids  => [@dialect.id]
        }})
      end

      it "redirects to url(:gluttonberg_locales)" do
        @response.should redirect_to(url(:gluttonberg_locales))
      end
      
      it "should add locale" do
        Locale.first.should_not be_nil
      end
      
      it "has the correct dialect" do
        Locale.first.dialects.include?(@dialect).should be_true
      end
    end
  end

  describe "url(:gluttonberg_locale, @locale)" do 
    describe "a successful DELETE", :given => "a locale exists" do
       before(:each) do
         @response = request(url(:gluttonberg_locale, Locale.first), :method => "DELETE")
       end

       it "should redirect to the index action" do
         @response.should redirect_to(url(:gluttonberg_locales))
       end
     end
  end

  describe "url(:new_gluttonberg_locale)" do
    before(:each) do
      @response = request(url(:new_gluttonberg_locale))
    end

    it "responds successfully" do
      @response.should be_successful
    end
    
    it "should contain a form" do
      @response.should have_selector("#wrapper form")
    end
  end

  describe "url(:edit_gluttonberg_locale, @locale)", :given => "a locale exists" do
    before(:each) do
      @response = request(url(:edit_gluttonberg_locale, Locale.first))
    end

    it "responds successfully" do
      @response.should be_successful
    end
  end

  describe "url(:gluttonberg_locale, @locale)", :given => "a locale exists" do

    describe "PUT" do
      before(:each) do
        @response = request(url(:gluttonberg_locale, Locale.first), :method => "PUT", 
          :params => { "gluttonberg::locale" => {:name => "Weppa!"} })
      end

      it "redirect to the index action" do
        @response.should redirect_to(url(:gluttonberg_locales))
      end
      
      it "should update the name of the model" do
        Locale.first.name.should == "Weppa!"
      end
    end

  end
end
