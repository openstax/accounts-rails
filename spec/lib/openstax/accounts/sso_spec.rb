require 'spec_helper'


module OpenStax
  module Accounts
    RSpec.describe Sso do

      let(:mock_request) do
        OpenStruct.new(
          cookies: {
            'ox' => "eEkxbm4zQ1kzaG9oWnFFVCs1amV0ajRxYlBXc0NScDFueTFPU1FqSDRtZ3ZlcWFQbVk2SEx6UGtQYVcvMld5aWhYL05TVDJOV3Zjb2x3ZHlkNUdCck5hdGw0bk0vSW0xTFQwdjRlTE1Vcnk0NmNqQWdEbUV5YmE2dkdWdk9UNk1tc3pEdWFMc3Bob0NvWk5QMXhGNUt6U3A1SmhhOGVsajlnN1l0a1dFZlhFQndvYk4wd0wyQTljZ3haMnk5S0EwaXA4SkNQRDRpUUhLK1crTXA0clNhcWp1bUhCajdjUExEdEVYSVVSTWsrN2t2ek9XcEVqVURQeXkxZndLNHFSUlNPRVQ5T3kzZ3MwRWNrbmRhOVY4a29DdXlEWkc4L3V5S0JmVi9jTWk1b1NjUmsvNXN1VG80b0UvNU90ZGUxcnJMV0xIay9MZ1FrWkJYZGw0U2UzM093PT0tLWRiNDU3Unc3MTJPZDQxSzlLQVM0aEE9PQ==--3684c383b8b6d2b073f8f31fe3a58a583fed74bf"
          }
        )
      end

      it 'decrypts' do
        expect(OpenStax::Accounts::Sso.decrypt(mock_request)).to eq(
          'user' => {
            "id"=>1,
            "uuid"=>"f0cb40a7-d644-41ed-ba93-9fccfad72ffd",
            "support_identifier"=>"cs_18cc12a9",
            "is_test"=>false,
            "applications"=>[]
          }
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
