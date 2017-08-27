require 'spec_helper'

describe "Signed login", type: :request do

  context 'without stubbing' do
    around(:each) {|example| with_stubbing(false){ example.run}}

    it 'signs the login params' do
      get '/accounts/signed_login?go=somewhere'
      expect(redirect_query_hash[:signature]).to be_a String
      expect(redirect_query_hash[:timestamp]).to be_a String
      expect(redirect_query_hash[:go]).to eq "somewhere"
      expect(redirect_path).to eq "/accounts/auth/openstax"

      # Pretend like we are receiving the signature and check that it is good
      params = redirect_query_hash
      incoming_signature = params.delete(:signature)
      normalized_params_string = OpenStax::Accounts::QueryHelper.normalize(params)
      computed_signature = OpenSSL::HMAC.hexdigest(
                             'sha1',
                             OpenStax::Accounts.configuration.openstax_application_secret,
                             normalized_params_string
                            )
      expect(incoming_signature).to eq computed_signature
    end
  end

end
