ActionInterceptor.configure do

  interceptor :authenticate_user! do
    account = current_account

    return if account && !account.is_anonymous?

    respond_to do |format|
      format.html { redirect_to registration_path }
      format.json { head(:forbidden) }
    end
  end

end
