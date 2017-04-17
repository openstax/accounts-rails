module OpenStax
  module Accounts
    module RemoteHelper
      def accounts_loader_script_tag
        javascript_include_tag openstax_accounts.remote_js_loader_url
      end
    end
  end
end
