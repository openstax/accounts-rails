connect-rails
=============

A rails engine for interfacing with OpenStax's common accounts server.

Usage
-----

Add the engine to your Gemfile and then run `bundle install`.  

Mount the engine your application's `routes.rb` file:

    MyApplication::Application.routes.draw do
      ...
      mount OpenStax::Connect::Engine, at: "/connect"
      ...
     end

You can use whatever path you want instead of `/connect`, just make sure to make the appropriate changes below.

Create an `openstax_connect.rb` initializer in `config/initializers`, with the following contents:

    OpenStax::Connect.configure do |config|
      config.openstax_application_id = 'value_from_openstax_accounts_here'
      config.openstax_application_secret = 'value_from_openstax_accounts_here'
    end

If you're running OpenStax Accounts in a dev instance on your machine, you can specify that instance's local URL with:

    config.openstax_accounts_url = 'http://localhost:2999/'

To have users login, direct them to `/connect/sessions/new`.  This is also available through the `openstax_connect.login` route helper, e.g. `<%= link_to 'Sign in!', openstax_connect.login_path %>`.

There is also a logout path helper for `/connect/sessions/destroy`, given by `logout_path`.  By default this expects a `GET` request.  If you'd prefer a `DELETE` request, add this configuration:

    config.logout_via = :delete

OpenStax Connect provides you with an `OpenStax::Connect::User` object.  You can
use this as your app's User object without modification, you can modify it to suit
your app's needs (not recommended), or you can provide your own custom User object
that references the OpenStax Connect User object.  

OpenStax Connect also provides you methods for getting and setting the current 
signed in user (`current_user` and `current_user=` methods).  If you choose to create 
your own custom User object that references the User object provide by Connect, 
you can teach OpenStax Connect how to translate between your app's custom User 
object and OpenStax Connect's built-in User object.

To do this, you need to set a `user_provider` in this configuration.  

    config.user_provider = MyUserProvider

The user_provider is a class that provides two class methods:

    def self.connect_user_to_app_user(connect_user)
      # converts the given connect user to an app user
      # if you want to cache the connect_user in the app user
      # this is the place to do it.
      # If no app user exists for this connect user, one should
      # be created.
    end
  
    def self.app_user_to_connect_user(app_user)
      # converts the given app user to a connect user
    end 

Connect users are never nil.  When a user is signed out, the current connect user 
is an anonymous user (responding true to `is_anonymous?`).  You can follow the same
pattern in your app or you can use nil for the current user.  Just remember to check
the anonymous status of connect users when doing your connect <-> app translations.

The default `user_provider` just uses OpenStax::Connect::User as the app user.

Make sure to install the engine's migrations:

    rake openstax_connect:install:migrations

Accounts API
------------

OpenStax::Connect provides convenience methods for accessing the OpenStax Accounts API.

`OpenStax::Connect.create_application_user(user, version = nil)` takes
an OpenStax::Connect::User and, optionally, an API version argument, and creates
an ApplicationUser for the configured application and the given user. Call this method
when users finish the registration process in your app.

`OpenStax::Connect.api_call(http_method, url, options = {})` provides a generic
convenience method capable of making API calls to Accounts. `http_method` can be
any valid HTTP method, and `url` is the desired API URL, without the 'api/' prefix.
Options is a hash that can contain any option that OAuth2 requests accept, such
as :headers, :params, :body, etc, plus the optional values :api_version (to specify
an API version) and :access_token (to specify an OAuth access token).

Example Application
-------------------

There is an example application included in the gem in the `example` folder.  Here are steps
to follow:

1. Download (clone) the OpenStax Accounts site from github.com/openstax/accounts.  
1. In the site's `config` folder put a `secret_settings.yml` file that has values for the 
following keys: `facebook_app_id`, `facebook_app_secret`, `twitter_consumer_key`, `twitter_consumer_secret`.  If you
don't have access to these values, you can always make dummy apps on facebook and twitter.
2. Do the normal steps to get this site online: 
    1. Run `bundle install --without production`
    2. Run `bundle exec rake db:migrate`
    3. Run `bundle exec rails server`
2. Open this accounts site in a web browser (defaults to http://localhost:2999)
3. Navigate to http://localhost:2999/oauth/applications
4. Click `New application`
    5. Set the callback URL to `http://localhost:4000/connect/auth/openstax/callback`.  
Port 4000 is where you'll be running the example application.
    1. The name can be whatever.
    2. Click the `Trusted?` checkbox.
    3. Click `Submit`.
    4. Keep this window open so you can copy the application ID and secret into the example app
5. Leave the accounts app running
6. Download (clone) the OpenStax Connect gem from github.com/openstax/connect-rails.  The
example application is in the `example` folder.  In that folder's config folder, create a `secret_settings.yml` file 
according to the instructions in `secret_settings.yml.example`.  Run the example server in the normal way (bundle install..., migrate db, rails server).
7. Navigate to the home page, http://localhost:4000.  Click log in and play around.  You can also refresh the accounts site and see yourself logged in, log out, etc.
8. For fun, change example/config/openstax_connect.rb to set `enable_stubbing` to `true`.  Now when you click login you'll be taken to a developer-only page where you can login as other users, generate new users, create new users, etc.