require 'spec_helper'

module OpenStax
  module Accounts

    RSpec.describe SessionsCallback do

      context "faculty_status" do
        it "should default to no_faculty_info if the received faculty_status is unknown" +
           " (e.g. if Accounts is updated but this repo is not)" do
          result = described_class.handle(
            request: mock_omniauth_request(faculty_status: "howdy_ho")
          )
          expect(result.outputs.account).to be_no_faculty_info
        end

        it "should default to no_faculty_info if faculty status is not present" do
          request = mock_omniauth_request()
          remove_faculty_status!(request)
          result = described_class.handle(request: request)
          expect(result.outputs.account).to be_no_faculty_info
        end

        it "should deal with null nicknames" do
          with_stubbing(false) do
            request = mock_omniauth_request
            remove_nickname!(request)
            result = described_class.handle(request: request)
            expect(result.outputs.account).to be_valid
            expect(result.outputs.account).to be_persisted
          end
        end
      end

      context "uuid" do
        it "sets the UUID on the account" do
          uuid = SecureRandom.uuid
          result = described_class.handle(request: mock_omniauth_request(uuid: uuid))
          expect(result.outputs.account.uuid).to eq uuid
        end
      end

      context "support_identifier" do
        it "sets the support_identifier on the account" do
          support_identifier = "cs_#{SecureRandom.hex(4)}"
          result = described_class.handle(
            request: mock_omniauth_request(support_identifier: support_identifier)
          )
          expect(result.outputs.account.support_identifier).to eq support_identifier
        end
      end

      context "role" do
        it "sets the role on the account" do
          result = described_class.handle(
            request: mock_omniauth_request(self_reported_role: "instructor")
          )
          expect(result.outputs.account.role).to eq "instructor"
        end

        it "deals with unknown role (e.g. if Accounts update but this repo not)" do
          result = described_class.handle(
            request: mock_omniauth_request(self_reported_role: "howdy_ho")
          )
          expect(result.outputs.account).to be_unknown_role
        end
      end

      context "user exists" do
        it "updates the user's data" do
          existing_account = FactoryBot.create :openstax_accounts_account
          uuid = SecureRandom.uuid
          support_identifier = "cs_#{SecureRandom.hex(4)}"
          result = described_class.handle(
            request: mock_omniauth_request(
              uid: existing_account.openstax_uid,
              first_name: "1234",
              last_name: "5678",
              title: "900",
              nickname: "191919",
              faculty_status: "confirmed_faculty",
              uuid: uuid,
              support_identifier: support_identifier,
              self_reported_role: "instructor")
          )

          account = result.outputs.account.reload
          expect(account.id).to eq existing_account.id
          expect(account.first_name).to eq "1234"
          expect(account.last_name).to eq "5678"
          expect(account.title).to eq "900"
          expect(account.username).to eq "191919"
          expect(account).to be_confirmed_faculty
          expect(account.uuid).to eq uuid
          expect(account.support_identifier).to eq support_identifier
          expect(account).to be_instructor
        end
      end

    end

  end
end
