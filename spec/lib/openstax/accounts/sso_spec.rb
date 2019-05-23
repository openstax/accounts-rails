require 'spec_helper'


module OpenStax
  module Accounts
    RSpec.describe Sso do

      let(:mock_request) do
        OpenStruct.new(
          cookies: {
            'ox' => 'rHYo4mcrfC7q4zwvONJwUFXn2jAFvstsGGcdPsOUcQO6RYT/BgZdOn9ZCv+OSxRb+eX9O+MHVYVJp4kwD8jnJTq1TfHLcetn0JoRlpYhx9yzU7GynvPa+6Am3McHhOkuA6FNYne184DCBru16e1YUiIB+UdII9GKsIkP--ZhszDn22tN9eASU0--o/AVN/yMC2NM0Uhba3yIZw=='
          }
        )
      end

      it 'decrypts' do
        expect(OpenStax::Accounts::Sso.decrypt(mock_request)).to eq(
          'user' => {
            id: 1,
            username: 'admin',
            uuid: '4ad8b085-a999-4a16-93a0-d78d4f21aba2',
            first_name: 'Admin',
            last_name: 'Admin'
          }.stringify_keys
        )
      end

      it 'returns whatever the cookie contains' do
        encryptor = OpenStax::Accounts::Sso.send(:encryptor)
        mock_request.cookies['ox'] = encryptor.encrypt_and_sign(%w{ this is not a hash })
        expect(
          OpenStax::Accounts::Sso.decrypt(mock_request)
        ).to eq(['this', 'is', 'not', 'a', 'hash'])
      end

      it 'returns empty on an invalid cookie' do
        mock_request.cookies['ox'] = 'bad!'
        expect(OpenStax::Accounts::Sso.decrypt(mock_request)).to eq({})
      end

    end
  end
end
