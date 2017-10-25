module OpenStax
  module Accounts
    class SearchLocalAccounts

      ACCOUNTS = OpenStax::Accounts::Account.arel_table

      SORTABLE_FIELDS = {
        'username' => :username,
        'first_name' => :first_name,
        'last_name' => :last_name,
        'full_name' => :full_name,
        'id' => :openstax_uid,
        'created_at' => :created_at
      }

      lev_routine

      uses_routine OSU::SearchAndOrganizeRelation, as: :search,
                   translations: { outputs: { type: :verbatim } }

      def exec(*args)
        params = args.last.is_a?(Hash) ? args.pop : {}
        params[:q] ||= args[0]
        params[:ob] ||= args[1]
        params[:pp] ||= args[2]
        params[:p] ||= args[3]



        run(:search, relation: OpenStax::Accounts::Account.unscoped,
                     sortable_fields: SORTABLE_FIELDS,
                     params: params) do |with|

          with.default_keyword :any

          with.keyword :username do |names|
            names.each do |name|
              sanitized_names = to_string_array(name, append_wildcard: true)
              next @items = @items.none if sanitized_names.empty?

              @items = @items.where(ACCOUNTS[:username].matches_any(sanitized_names))
            end
          end

          with.keyword :first_name do |names|
            names.each do |name|
              sanitized_names = to_string_array(name, append_wildcard: true)
              next @items = @items.none if sanitized_names.empty?

              @items = @items.where(ACCOUNTS[:first_name].matches_any(sanitized_names))
            end
          end

          with.keyword :last_name do |names|
            names.each do |name|
              sanitized_names = to_string_array(name, append_wildcard: true)
              next @items = @items.none if sanitized_names.empty?

              @items = @items.where(ACCOUNTS[:last_name].matches_any(sanitized_names))
            end
          end

          with.keyword :full_name do |names|
            names.each do |name|
              sanitized_names = to_string_array(name, append_wildcard: true)
              next @items = @items.none if sanitized_names.empty?

              @items = @items.where(ACCOUNTS[:full_name].matches_any(sanitized_names))
            end
          end

          with.keyword :name do |names|
            names.each do |name|
              sanitized_names = to_string_array(name, append_wildcard: true)
              next @items = @items.none if sanitized_names.empty?

              @items = @items.where(
                ACCOUNTS[:username].matches_any(sanitized_names)
                  .or(ACCOUNTS[:first_name].matches_any(sanitized_names))
                  .or(ACCOUNTS[:last_name].matches_any(sanitized_names))
                  .or(ACCOUNTS[:full_name].matches_any(sanitized_names))
              )
            end
          end

          with.keyword :id do |ids|
            ids.each do |id|
              sanitized_ids = to_string_array(id)
              next @items = @items.none if sanitized_ids.empty?
              @items = @items.where(ACCOUNTS[:openstax_uid].eq_any(sanitized_ids))
            end
          end

          with.keyword :any do |terms|
            terms.each do |term|
              sanitized_names = to_string_array(term, append_wildcard: true)
              sanitized_ids = to_string_array(term)
              next @items = @items.none if sanitized_names.empty? || sanitized_ids.empty?

              @items = @items.where(
                ACCOUNTS[:username].matches_any(sanitized_names)
                  .or(ACCOUNTS[:first_name].matches_any(sanitized_names))
                  .or(ACCOUNTS[:last_name].matches_any(sanitized_names))
                  .or(ACCOUNTS[:full_name].matches_any(sanitized_names))
                  .or(ACCOUNTS[:openstax_uid].eq_any(sanitized_ids))
              )
            end
          end

        end
      end
    end
  end
end
