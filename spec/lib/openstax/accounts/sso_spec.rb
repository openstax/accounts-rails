require 'spec_helper'


module OpenStax
  module Accounts
    RSpec.describe Sso do

      let(:mock_request) {
        OpenStruct.new(
          cookies: {
            'ox' => 'MnJMZ1gzdWJhVHR6eVQ4N2NqdDBxQ1RYMHU2NU1PLzVqZmdtUzRZSEI2YURIZ1NtV1RrU091UVBtOFV5RGRMQVVZN2plM1BlMVo1d0p5YUwxaWZQaW95RVFsUnlIaDZ4L3RIcDd2ZzlwQndJbVo3SU5lbUtuUUx6eXAyenZJUENDUzRSTndkNmdXTXNBTHFNL1VNbUEvSmthUnlLeGlqeUpWelc1YndCM29VPS0tYmZlcXliaXE4UWR6SXlhZEt4UklFZz09--dcd97b632fe6e700dc4e8629e70a66ee091d4f5d'
          }
        )
      }

      before(:each) do
        expect(OpenStax::Accounts.configuration).to(
          receive(:sso_secret_key).at_most(:once).and_return('1234567890abcd')
        )
      end

      it 'decrypts' do
        expect(
          OpenStax::Accounts::Sso.decrypt(mock_request)
        ).to eq(
                  'user' => {
                    id: 1, username: 'admin', uuid: '4ad8b085-a999-4a16-93a0-d78d4f21aba2',
                    first_name: 'Admin', last_name: 'Admin'
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
        expect(
          OpenStax::Accounts::Sso.decrypt(mock_request)
        ).to eq({})
      end

    end
  end
end
