require 'squeel'

module OpenStax
  module Accounts

    class SearchUsers
      lev_routine transaction: :no_transaction

    protected

      def exec(terms, type=:any)
        # Return empty results if no search terms
        return User.where{id == nil}.where{id != nil} if terms.blank?

        # Note: % is the wildcard. This allows the user to search
        # for stuff that "begins with" but not "ends with".
        case type
        when :name
          users = User.scoped
          terms.gsub(/[%,]/, '').split.each do |t|
            next if t.blank?
            query = t + '%'
            users = users.where{(first_name =~ query) | (last_name =~ query)}
          end
        when :username
          query = terms.gsub('%', '') + '%'
          users = User.where{username =~ query}
        when :any
          users = User.scoped
          terms.gsub(/[%,]/, '').split.each do |t|
            next if t.blank?
            query = t + '%'
            users = users.where{(first_name =~ query) | 
                        (last_name =~ query) |
                        (username =~ query)}
          end
        else
          fatal_error(:unknown_user_search_type, data: type)
        end

        outputs[:users] = users
      end

    end

  end
end