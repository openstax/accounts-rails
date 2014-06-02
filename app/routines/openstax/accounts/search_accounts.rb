# Routine for searching for users
#
# Caller provides a query and some options.  The query follows the rules of
# https://github.com/bruce/keyword_search , e.g.:
#
#   "username:jps,richb" --> returns the "jps" and "richb" users
#   "name:John" --> returns Users with first, last, or full name
#                   starting with "John"
#
# Query terms can be combined, e.g. "username:jp first_name:john"
#
# There are currently two options to control query pagination:
#
#   :per_page -- the max number of results to return per page (default: 20)
#   :page     -- the zero-indexed page to return (default: 0)
#
# There is also an option to control the ordering:
#
#   :order_by -- comma-separated list of fields to sort by, with an optional
#                space-separated sort direction (default: "username ASC")
#
# Finally, you can also specify a maximum allowed number of results:
#
#   :max_matching_users -- the max number of results allowed (default: 10)
#
# This routine will return an empty relation if the number of results exceeds
# max_matching_users. You can tell that this happened because the result will
# have a non-zero num_matching_users.

module OpenStax
  module Accounts
    class SearchUsers
      
      lev_routine transaction: :no_transaction
      
      protected
      
      SORTABLE_FIELDS = ['username', 'first_name', 'last_name', 'id']
      SORT_ASCENDING = 'ASC'
      SORT_DESCENDING = 'DESC'

      def exec(query, options={})

        if !OpenStax::Accounts.configuration.enable_stubbing? &&\
           KeywordSearch.search(query).values_at('email', :default).compact.any?
          # Delegate to Accounts

          response = OpenStax::Accounts.application_users_index(query)

          user_search = OpenStruct.new
          search_rep = OpenStax::Accounts::Api::V1::UserSearchRepresenter.new(user_search)
          search_rep.from_json(response.body)

          # Need to query local database in order to obtain ID's (primary keys)
          outputs[:users] = OpenStax::Accounts::User.where{
                              openstax_uid.in user_search.users.collect{ |u| u.openstax_uid }
                            }
          outputs[:query] = user_search.q
          outputs[:per_page] = user_search.per_page
          outputs[:page] = user_search.page
          outputs[:order_by] = user_search.order_by
          outputs[:num_matching_users] = user_search.num_matching_users

        else

          # Local search
          users = OpenStax::Accounts::User.scoped

          KeywordSearch.search(query) do |with|

            with.default_keyword :any

            with.keyword :username do |usernames|
              users = users.where{username.like_any my{prep_usernames(usernames)}}
            end

            with.keyword :first_name do |first_names|
              users = users.where{lower(first_name).like_any my{prep_names(first_names)}}
            end

            with.keyword :last_name do |last_names|
              users = users.where{lower(last_name).like_any my{prep_names(last_names)}}
            end

            with.keyword :full_name do |full_names|
              users = users.where{lower(full_name).like_any my{prep_names(full_names)}}
            end

            with.keyword :name do |names|
              names = prep_names(names)
              users = users.where{ (lower(full_name).like_any names)  |
                                   (lower(last_name).like_any names)  |
                                   (lower(first_name).like_any names) }
            end

            with.keyword :id do |ids|
              users = users.where{openstax_uid.in ids}
            end

            with.keyword :email do |emails|
              users = OpenStax::Accounts::User.where('0=1')
            end

            # Rerun the queries above for 'any' terms (which are ones without a
            # prefix).  

            with.keyword :any do |terms|
              names = prep_names(terms)

              users = users.where{
                                    (  lower(username).like_any  my{prep_usernames(terms)}) |
                                    (lower(first_name).like_any  names)                     |
                                    (lower(last_name).like_any   names)                     |
                                    (lower(full_name).like_any   names)                     |
                                    (id.in                       terms)
                                 }
            end

          end
          
          # Pagination
          
          page = options[:page] || 0
          per_page = options[:per_page] || 20
          
          users = users.limit(per_page).offset(per_page*page)
          
          #
          # Ordering
          #
          
          # Parse the input
          order_bys = (options[:order_by] || 'username').split(',').collect{|ob| ob.strip.split(' ')}
          
          # Toss out bad input, provide default direction
          order_bys = order_bys.collect do |order_by|
            field, direction = order_by
            next if !SORTABLE_FIELDS.include?(field)
            direction ||= SORT_ASCENDING
            next if direction != SORT_ASCENDING && direction != SORT_DESCENDING
            [field, direction]
          end
          
          order_bys.compact!
          
          # Use a default sort if none provided
          order_bys = ['username', SORT_ASCENDING] if order_bys.empty?
          
          # Convert to query style
          order_bys = order_bys.collect{|order_by| "#{order_by[0]} #{order_by[1]}"}
          
          # Make the ordering call
          order_bys.each do |order_by|
            users = users.order(order_by)
          end
          
          # Translate to routine outputs
          
          outputs[:users] = users
          outputs[:query] = query
          outputs[:per_page] = per_page
          outputs[:page] = page
          outputs[:order_by] = order_bys.join(', ') # convert back to one string
          outputs[:num_matching_users] = users.except(:offset, :limit, :order).count

        end

        # Return no results if query exceeds maximum allowed number of matches
        max_users = options[:max_matching_users] || \
                    OpenStax::Accounts.configuration.max_matching_users
        outputs[:users] = OpenStax::Accounts::User.where('0=1') \
          if outputs[:num_matching_users] > max_users

      end
      
      # Downcase, and put a wildcard at the end.
      # For the moment don't exclude characters.
      def prep_names(names)
        names.collect{|name| name.downcase + '%'}
      end
      
      def prep_usernames(usernames)
        usernames.collect{|username| username.gsub(OpenStax::Accounts::User::USERNAME_DISCARDED_CHAR_REGEX, '').downcase + '%'}
      end

    end

  end
end
