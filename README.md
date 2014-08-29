accounts-rails
=============

[![Gem Version](https://badge.fury.io/rb/openstax_accounts.svg)](http://badge.fury.io/rb/openstax_accounts)
[![Build Status](https://travis-ci.org/openstax/accounts-rails.svg?branch=master)](https://travis-ci.org/openstax/accounts-rails)
[![Code Climate](https://codeclimate.com/github/openstax/accounts-rails/badges/gpa.svg)](https://codeclimate.com/github/openstax/accounts-rails)

A rails engine for interfacing with OpenStax's accounts server.

Installation
------------

Make sure to install the engine's migrations:

```sh
$ rake openstax_accounts:install:migrations
```

Usage
-----

Add the engine to your Gemfile and then run `bundle install`.

Mount the engine your application's `routes.rb` file:

```rb
  MyApplication::Application.routes.draw do
    # ...
    mount OpenStax::Accounts::Engine, at: "/accounts"
    # ...
  end
```

You can use whatever path you want instead of `/accounts`,
just make sure to make the appropriate changes below.

Create an `openstax_accounts.rb` initializer in `config/initializers`,
with at least the following contents:

```rb
OpenStax::Accounts.configure do |config|
  config.openstax_application_id = 'value_from_openstax_accounts_here'
  config.openstax_application_secret = 'value_from_openstax_accounts_here'
end
```

If you're running the OpenStax Accounts server in a dev instance on your
machine, you can specify that instance's local URL with:

```rb
config.openstax_accounts_url = 'http://localhost:2999/'
```

To have users login, direct them to the login path using the
`openstax_accounts.login_path` route helper with Action Interceptor, e.g:

```erb
<%= link_to 'Sign in!', with_interceptor { openstax_accounts.login_path } %>
```

The `with_interceptor` block is necessary if you don't want to
depend on the user's browser setting referers properly.

You can also add the `authenticate_user!` interceptor to your controllers:

```rb
interceptor :authenticate_user!
```

There is also a logout path helper, given by `logout_path`.
By default this expects a `GET` request.
If you'd prefer a `DELETE` request, add this configuration:

```rb
config.logout_via = :delete
```

OpenStax Accounts provides you with an `OpenStax::Accounts::Account` object.
You can modify it and use this as your app's User object (not recommended),
or you can provide your own custom user object that references one account.

OpenStax Accounts also provides you methods for getting and setting the current
signed in user (`current_user` and `current_user=` methods).  If you choose to
create your own custom user object, you can teach this gem how to translate
between a user object and an account object.

To do this, you need to set a `account_user_mapper` in this configuration.  

    config.account_user_mapper = MyAccountUserMapper

The account_user_mapper is a class that provides two class methods:

    def self.account_to_user(account)
      # Converts the given account to a user.
      # If you want to cache the account in the user,
      # this is the place to do it.
      # If no user exists for this account, one should
      # be created.
    end
  
    def self.user_to_account(user)
      # Converts the given user to an account.
    end 

Accounts are never nil. When a user is signed out, the current account is the
AnonymousAccount (responding true to `is_anonymous?`). You can follow the same
pattern in your app or you can use nil for the current user. Just remember to
check the anonymous status of accounts when doing your account <-> user
translations.

The default `account_user_mapper` assumes the account object and
the user object are the same in your application.

Syncing with Accounts
---------------------

OpenStax Accounts requires your app to periodically sync user information with
the Accounts server. The easiest way to do this is to use the "whenever" gem.

To create or append to the schedule.rb file, run the following command:

```sh
rails g openstax:accounts:schedule
```

Then, after installing the "whenever" gem, run the `whenever` command for
instructions to set up your crontab:

```sh
whenever
```

Accounts API
------------

OpenStax Accounts provides convenience methods for accessing
the Accounts server API.

`OpenStax::Accounts.api_call(http_method, url, options = {})` provides a
convenience method capable of making API calls to Accounts. `http_method` can
be any valid HTTP method, and `url` is the desired API URL, without the 'api/'
prefix. Options is a hash that can contain any option that
OAuth2 requests accept, such as :headers, :params, :body, etc,
plus the optional values :api_version (to specify an API version) and
:access_token (to specify an OAuth access token).

Example Application
-------------------

There is an example application included in the gem in the `example` folder.
Here are the steps to follow:

1. Download (clone) the OpenStax Accounts site from github.com/openstax/accounts.  
1. In the site's `config` folder put a `secret_settings.yml` file that has values for the 
following keys: `facebook_app_id`, `facebook_app_secret`, `twitter_consumer_key`, `twitter_consumer_secret`.  If you don't have access to these values, you can always make dummy apps on facebook and twitter.
2. Do the normal steps to get this site online:
    1. Run `bundle install --without production`
    2. Run `bundle exec rake db:migrate`
    3. Run `bundle exec rails server`
2. Open this accounts site in a web browser (defaults to http://localhost:2999)
3. Navigate to http://localhost:2999/oauth/applications
4. Click `New application`
    5. Set the callback URL to `http://localhost:4000/accounts/auth/openstax/callback`.  
Port 4000 is where you'll be running the example application.
    1. The name can be whatever.
    2. Click the `Trusted?` checkbox.
    3. Click `Submit`.
    4. Keep this window open so you can copy the application ID and secret into the example app
5. Leave the accounts app running
6. Download (clone) the OpenStax Accounts gem from github.com/openstax/accounts-rails. 
The example application is in the `example` folder.
In that folder's config folder, create a `secret_settings.yml` file according to the
instructions in `secret_settings.yml.example`. Run the example server in the normal way (bundle install..., migrate db, rails server).
7. Navigate to the home page, http://localhost:4000.  Click log in and play around.  You can also refresh the accounts site and see yourself logged in, log out, etc.
8. For fun, change example/config/openstax_accounts.rb to set `enable_stubbing` to `true`.  Now when you click login you'll be taken to a developer-only page where you can login as other users, generate new users, create new users, etc.