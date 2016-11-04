require 'spec_helper'

module OpenStax::Accounts
  RSpec.describe Account do
    subject(:account) { FactoryGirl.create(:openstax_accounts_account) }

    context 'validation' do
      it 'requires a unique openstax_uid, if given' do
        account.openstax_uid = nil
        expect(account).to be_valid

        account.openstax_uid = -1
        account.save!

        account_2 = FactoryGirl.build(:openstax_accounts_account, openstax_uid: -1)
        expect(account_2).not_to be_valid
        expect(account_2.errors[:openstax_uid]).to eq(['has already been taken'])
      end
    end

    context 'updates' do
      before do
        account.syncing = false
        account.openstax_uid = 1
        account.account_type = :remote
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
            context 'local account' do
              before { account.account_type = :local }

              it 'does not send updates to accounts' do
                expect(OpenStax::Accounts::Api).not_to receive(:update_account)

                account.username = 'Local User'
                account.save!
              end
            end

            context 'remote account' do
              it 'does not send updates to accounts' do
                expect(OpenStax::Accounts::Api).to receive(:update_account).once

                account.username = 'Remote User'
                account.save!
              end
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
