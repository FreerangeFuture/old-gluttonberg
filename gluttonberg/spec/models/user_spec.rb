require File.join( File.dirname(__FILE__), '..', "spec_helper" )

module Gluttonberg
  describe User do

    it "should create new record" do
      User.all.destroy!
      @user = User.create(
        :name                   => "Luke Sutton", 
        :email                  => "luke@freerangefuture.com", 
        :password               => "password", 
        :password_confirmation  => "password"
      )
      User.first.should_not be_nil
    end

  end
end