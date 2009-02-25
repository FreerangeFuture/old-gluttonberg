module Gluttonberg
  # A hacky looking class to give us redirects, since using the redirect action
  # in a defer to block has some issues with scoping.
  #
  # FIXME: Remove all this code entirely *sigh*
  class Redirect < Merb::Controller
    def to
      redirect params[:redirect_url]
    end
  end
end
