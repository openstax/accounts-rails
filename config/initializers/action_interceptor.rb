ActionInterceptor.configure do

  # interceptor(interceptor_name, &block)
  # Type: Method
  # Arguments: interceptor name (Symbol or String),
  #            &block (Proc)
  # Defines an interceptor.
  # Default: none
  # Example: interceptor :my_name do
  #            redirect_to my_action_users_url if some_condition
  #          end
  #
  #          (Conditionally redirects to :my_action in UsersController)
  interceptor :authenticate_user! do
    # For API controllers
    user = (request.format == :json) ? current_human_user : current_user

    return if user && !user.is_anonymous?

    respond_to do |format|
      format.html { redirect_to registration_path }
      format.json { head(:forbidden) }
    end
  end

end
