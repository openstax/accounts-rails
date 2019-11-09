namespace :openstax do
  namespace :accounts do
    namespace :sync do
      desc "Sync Accounts with OpenStax Accounts"
      task accounts: :environment do
        OpenStax::Accounts::SyncAccounts.call
      end
    end
  end
end
