namespace :openstax do
  namespace :accounts do
    namespace :sync do
      desc "Sync Accounts with OpenStax Accounts"
      task accounts: :environment do
        OpenStax::Accounts::SyncAccounts.call
      end

      desc "Sync Groups with OpenStax Accounts"
      task groups: :environment do
        OpenStax::Accounts::SyncGroups.call
      end

      desc "Sync Accounts and Groups with OpenStax Accounts"
      task all: [:accounts, :groups]
    end
  end
end
