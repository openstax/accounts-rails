module OpenStax
  module Connect
    module Dev
      class UsersController < DevController
        
        def login; end

        def search
          handle_with(Dev::UsersSearch,
                      complete: lambda { render 'search' })
        end

        def become
          sign_in(User.find(params[:user_id]))
          redirect_to return_url(true)
        end

      end
    end
  end
end