class ActionController::Base

  # Returns the current app user
  def current_user
    current_user_manager.current_user
  end

  # Signs in the given user; the argument can be either an accounts user or
  # an app user
  def sign_in(user)
    current_user_manager.sign_in(user)
  end

  # Signs out the current user
  def sign_out!
    current_user_manager.sign_out!
  end

  # Returns true iff there is a user signed in
  def signed_in?
    current_user_manager.signed_in?
  end

  # Useful in before_filters
  def authenticate_user!
    return if signed_in?
    session[:return_to] = "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
    redirect_to openstax_accounts.login_path
  end

protected

  helper_method :current_user, :signed_in?

  def current_user_manager
    @current_user_manager ||= OpenStax::Accounts::CurrentUserManager.new(request,
                                                                         session,
                                                                         cookies)
  end

end

