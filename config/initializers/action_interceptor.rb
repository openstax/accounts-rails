ActionInterceptor.configure do

  interceptor :authenticate_user! do
    # For API controllers
    user = respond_to?(:current_human_user) ? current_human_user : current_user

    return if user && !user.is_anonymous?

    respond_to do |format|
      format.html { redirect_to registration_path }
      format.json { head(:forbidden) }
    end
  end

end
