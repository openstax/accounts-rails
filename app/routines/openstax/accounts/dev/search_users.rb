# Routine for searching for users
#
# Caller provides a query and some options.  The query follows the rules of
# https://github.com/bruce/keyword_search, e.g.:
#
#   "username:jps,richb" --> returns the "jps" and "richb" users
#   "name:John" --> returns Users with first, last, or full name starting with "John"
#
# Query terms can be combined, e.g. "username:jp first_name:john"
#
# There are currently two options to control query pagination:
#
#   :per_page -- the max number of results to return (default: 20)
#   :page     -- the zero-indexed page to return (default: 0)

module OpenStax
  module Accounts
    module Dev
      class SearchUsers < OpenStax::Accounts::SearchUsers
        def exec(query, options={})
          options = options.merge!(:max_matching_users => Float::INFINITY)
          super
        end
      end
    end
  end
end
