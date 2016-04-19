require 'spec_helper'

describe "Controllers that use this engine", type: :controller do

  controller do
    before_filter :authenticate_user!
    def action_needing_authentication; end
  end

  it 'should not freak out for what rails thinks are weird formats' do
    # When accounts-rails intercepts a request to authenticate a user and that request
    # has what Rails sees as a weird format, e.g.:
    #   https://example.org/qa/271/section/4.6
    # it was freaking out.  This spec makes sure it handles that kind of request URL

    routes.draw { get "action_needing_authentication" => "anonymous#action_needing_authentication" }

    expect{
      get :action_needing_authentication, format: :'6'
    }.not_to raise_error
  end
end
