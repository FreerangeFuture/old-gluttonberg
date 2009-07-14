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
      puts "=================================="+new_pass
      #message[:notice] = "We have sent you an email with a new password."      
      redirect slice_url(:login, :message => {:notice => "We have sent you an email with a new password."})
    end  
    
    def index
      render
    end
    
  end
end