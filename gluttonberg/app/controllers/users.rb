module Gluttonberg
  class Users < Gluttonberg::Application
  
    #layout("gluttonberg")
    
    def forgot_password
      render :layout => "bare"
    end  
    
    def reset
      @user = User.first(:email=>params[:email])
      new_pass = User.random_password
      @user.password = @user.password_confirmation = new_pass
      @user.save!
      body = "here is new password \n #{new_pass}"      
      puts "=================================="+new_pass
      m = Merb::Mailer.new( :to => @user.email,
                     :from => "rauf_eng@hotmail.com",
                     :subject => "Admin New Password",
                     :text => body)
      m.deliver!
      redirect slice_url(:login, :message => {:notice => "We have sent you an email with a new password."})
    end  
    
    def index
      render
    end
    
  end
end