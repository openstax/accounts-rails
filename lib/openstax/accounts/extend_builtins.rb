ActionController::Base.class_exec do

  helper_method :current_user, :signed_in?

  # Returns the current user
  def current_user
    current_user_manager.current_user
  end

  # Returns the current account
  def current_account
    current_user_manager.current_account
  end

  # Returns true iff there is a user signed in
  def signed_in?
    current_user_manager.signed_in?
  end

  # Signs in the given account or user
  def sign_in(user)
    current_user_manager.sign_in(user)
  end

  # Signs out the current account and user
  def sign_out!
    current_user_manager.sign_out!
  end

  protected

  def current_user_manager
    @current_user_manager ||= OpenStax::Accounts::CurrentUserManager.new(
                                request, session, cookies)
  end

end
