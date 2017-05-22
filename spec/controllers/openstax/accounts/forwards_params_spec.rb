require 'spec_helper'

describe "Forwards params", type: :request do

  class ForwardsParamsController < OpenStax::Accounts::ApplicationController
    before_filter :set_login_param
    before_filter :authenticate_user!

    def action_needing_authentication; end

    def set_login_param
      login_params[:signup_at] = "foo"
      login_params[:go] = "bar"
    end
  end

  before(:all) do
    Rails.application.routes.send(:eval_block, Proc.new do
      get '/forwards_params_route' => 'forwards_params#action_needing_authentication'
    end)
  end

  it 'should forward signup_at' do
    test_forwards(key: :signup_at, value: "foo")
  end

  it "should forward go" do
    test_forwards(key: :go, value: "bar")
  end

  def test_forwards(key:, value:)
    silence_omniauth do
      get '/forwards_params_route'

      expect(redirect_path).to eq "/accounts/login"
      expect(redirect_query_hash).to include(key => value)

      with_stubbing(false) do
        get redirect_path_and_query
      end

      expect(redirect_path).to eq "/accounts/auth/openstax"
      expect(redirect_query_hash).to include(key => value)

      get redirect_path_and_query

      expect(redirect_path).to eq("/oauth/authorize")
      expect(redirect_query_hash).to include(key => value)

      # This last redirect was to Accounts, so we don't follow it
    end
  end

  def redirect_path
    redirect_uri.path
  end

  def redirect_path_and_query
    "#{redirect_uri.path}?#{redirect_uri.query}"
  end

  def redirect_query_hash
    Rack::Utils.parse_nested_query(redirect_uri.query).symbolize_keys
  end

  def redirect_uri
    expect(response.code).to eq "302"
    uri = URI.parse(response.headers["Location"])
  end
end
