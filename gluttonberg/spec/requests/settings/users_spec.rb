require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

module Gluttonberg
  Settings::Users.skip_before(:ensure_authenticated)
  
  given "a user exists" do
    User.all.destroy!
    User.generate
  end
  
  describe "url(:gluttonberg_users)" do
    describe "GET" do
      before(:each) do 
        User.all.destroy!
        10.of { User.generate }
        @response = request(url(:gluttonberg_users))
      end

      it "responds successfully" do
        @response.should be_successful
      end

      it "contains a list of users" do
        @response.should have_selector("#wrapper table")
      end
    end

    describe "a successful POST" do
      before(:each) do
        User.all.destroy!
        @response = request(resource(:gluttonberg, :users), :method => "POST", 
          :params => { "gluttonberg::user" => {
            :name                   => "Luke Sutton",
            :email                  => "luke@freerangefuture.com",
            :password               => "password",
            :password_confirmation  => "password"
        }})
      end

      it "redirects to resource(:users)" do
        @response.should redirect_to(url(:gluttonberg_users))
      end
    end
  end

  describe "url(:gluttonberg_user, @user)" do 
    describe "a successful DELETE", :given => "a user exists" do
       before(:each) do
         @response = request(url(:gluttonberg_user, User.first), :method => "DELETE")
       end

       it "should redirect to the index action" do
         @response.should redirect_to(url(:gluttonberg_users))
       end
     end
  end

  describe "url(:new_gluttonberg_user)" do
    before(:each) do
      @response = request(url(:new_gluttonberg_user))
    end

    it "responds successfully" do
      @response.should be_successful
    end
  end

  describe "url(:edit_gluttonberg_user, @user)", :given => "a user exists" do
    before(:each) do
      @response = request(url(:edit_gluttonberg_user, User.first))
    end

    it "responds successfully" do
      @response.should be_successful
    end
  end

  describe "url(:gluttonberg_user, @user)", :given => "a user exists" do

    describe "PUT" do
      before(:each) do
        @user = User.first
        @response = request(url(:gluttonberg_user, @user), :method => "PUT", 
          :params => { "gluttonberg::user" => {:name => "Weppa!"} })
      end

      it "redirect to the index action" do
        @response.should redirect_to(url(:gluttonberg_users))
      end
      
      it "should update the name of the model" do
        User.first.name.should == "Weppa!"
      end
    end

  end
end
