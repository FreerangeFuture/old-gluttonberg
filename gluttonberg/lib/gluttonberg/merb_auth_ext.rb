# Temporary fix to handle additional content-types when authenticating.
module MerbAuthSlicePassword::ExceptionsMixin
  def unauthenticated
    provides :xml, :js, :json, :yaml
 
    case content_type
    when :html, :htmlf
      render
    else
      basic_authentication.request!
      ""
    end
  end # unauthenticated
end
