module OpenStax
  module Connect

    class ApplicationController < ActionController::Base
      include Lev::HandleWith

      # Override current_user to always return an OpenStax::Connect::User
      def current_user
        current_user_manager.connect_current_user
      end

    protected

      def return_url(include_referrer=false)
        referrer = include_referrer ? request.referrer : nil
        # Always clear the session
        session_return_to = session.delete(:return_to)
        params[:return_to] || session_return_to || referrer || main_app.root_url
      end

    end

  end
end
