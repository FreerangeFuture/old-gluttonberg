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
      m = Merb::Mailer.new( :to => @user.email,
                     :from => Merb::Slices::config[:gluttonberg][:email_from],
                     :subject => "Your New Password of #{website_title} Account",
                     :text => body)
      m.deliver!
      redirect slice_url(:login, :message => {:notice => "We have sent you an email with a new password."})
    end  
    
    def index
      render
    end
    
  end
end