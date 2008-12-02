require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

module Gluttonberg
  Settings::Dialects.skip_before(:ensure_authenticated)
  
  given "a dialect exists" do
    Dialect.all.destroy!
    Dialect.generate
  end
  
  describe "url(:gluttonberg_dialects)" do
    describe "GET" do
      before(:each) do 
        Dialect.all.destroy!
        10.of { Dialect.generate }
        @response = request(url(:gluttonberg_dialects))
      end

      it "responds successfully" do
        @response.should be_successful
      end

      it "contains a list of dialects" do
        @response.should have_selector("#wrapper table")
      end
    end

    describe "a successful POST" do
      before(:each) do
        Dialect.all.destroy!
        @response = request(url(:gluttonberg_dialects), :method => "POST", 
          :params => { "gluttonberg::dialect" => {:code => "en", :name => "English"}})
      end

      it "redirects to url(:gluttonberg_dialects)" do
        @response.should redirect_to(url(:gluttonberg_dialects))
      end
    end
  end

  describe "url(:gluttonberg_dialect, @dialect)" do 
    describe "a successful DELETE", :given => "a dialect exists" do
       before(:each) do
         @response = request(url(:gluttonberg_dialect, Dialect.first), :method => "DELETE")
       end

       it "should redirect to the index action" do
         @response.should redirect_to(url(:gluttonberg_dialects))
       end
     end
  end

  describe "url(:new_gluttonberg_dialect)" do
    before(:each) do
      @response = request(url(:new_gluttonberg_dialect))
    end

    it "responds successfully" do
      @response.should be_successful
    end
  end

  describe "url(:edit_gluttonberg_dialect, @dialect)", :given => "a dialect exists" do
    before(:each) do
      @response = request(url(:edit_gluttonberg_dialect, Dialect.first))
    end

    it "responds successfully" do
      @response.should be_successful
    end
  end

  describe "url(:gluttonberg_dialect, @dialect)", :given => "a dialect exists" do

    describe "PUT" do
      before(:each) do
        @dialect = Dialect.first
        @response = request(url(:gluttonberg_dialect, @dialect), :method => "PUT", 
          :params => { "gluttonberg::dialect" => {:name => "Weppa!"} })
      end

      it "redirect to the index" do
        @response.should redirect_to(url(:gluttonberg_dialects))
      end
      
      it "should update the name of the model" do
        Dialect.first.name.should == "Weppa!"
      end
    end

  end
end
