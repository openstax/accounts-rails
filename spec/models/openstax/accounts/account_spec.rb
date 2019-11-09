require 'spec_helper'

module OpenStax::Accounts
  RSpec.describe Account, type: :model do
    subject(:account) { FactoryBot.create(:openstax_accounts_account) }

    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:uuid).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:support_identifier).case_insensitive.allow_nil }

    context 'validation' do
      it 'allows nil username' do
        account.username = nil
        expect(account).to be_valid
      end

      it 'requires unique username if not nil' do
        expect{
          FactoryBot.create(:openstax_accounts_account, username: account.username)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'allows multiple accounts saved with nil username' do
        FactoryBot.create(:openstax_accounts_account, username: nil)
        expect{
          FactoryBot.create(:openstax_accounts_account, username: nil)
        }.not_to raise_error
      end

      it 'requires a role' do
        expect{
          FactoryBot.create(:openstax_accounts_account, role: nil)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'updates' do
      before do
        account.syncing = false
        account.openstax_uid = 1
      end

      context 'stubbing' do
        it 'does not send updates to accounts' do
          expect(OpenStax::Accounts::Api).not_to receive(:update_account)

          account.username = 'Stubbed User'
          account.save!
        end
      end

      context 'not stubbing' do
        before(:all) { OpenStax::Accounts.configuration.enable_stubbing = false }
        after(:all)  { OpenStax::Accounts.configuration.enable_stubbing = true }

        context 'syncing' do
          before{ account.syncing = true }

          it 'does not send updates to accounts' do
            expect(OpenStax::Accounts::Api).not_to receive(:update_account)

            account.username = 'Syncing User'
            account.save!
          end
        end

        context 'not syncing' do
          context 'invalid openstax_uid' do
            it 'does not send updates to accounts' do
              expect(OpenStax::Accounts::Api).not_to receive(:update_account)

              account.openstax_uid = nil
              account.username = 'Nil User'
              account.save!

              account.openstax_uid = 0
              account.username = 'Zeroth User'
              account.save!

              account.openstax_uid = -1
              account.username = 'Negative User'
              account.save!
            end
          end

          context 'valid openstax_uid' do
            it 'sends updates to accounts' do
              expect(OpenStax::Accounts::Api).to receive(:update_account).once

              account.username = 'Real User'
              account.save!
            end
          end
        end
      end
    end

    it 'is not anonymous' do
      expect(Account.new.is_anonymous?).to eq false
    end
  end
end
