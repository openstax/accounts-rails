module OpenStax
  module Accounts
    class SearchLocalAccountCache < OSU::AbstractKeywordSearchRoutine
      self.search_proc = lambda { |with|
        with.default_keyword :any

        with.keyword :username do |names|
          names.each do |name|
            sanitized_names = to_string_array(name, append_wildcard: true)
            @items = @items.where{username.like_any sanitized_names}
          end
        end

        with.keyword :first_name do |names|
          names.each do |name|
            sanitized_names = to_string_array(name, append_wildcard: true)
            @items = @items.where{first_name.like_any sanitized_names}
          end
        end

        with.keyword :last_name do |names|
          names.each do |name|
            sanitized_names = to_string_array(name, append_wildcard: true)
            @items = @items.where{last_name.like_any sanitized_names}
          end
        end

        with.keyword :full_name do |names|
          names.each do |name|
            sanitized_names = to_string_array(name, append_wildcard: true)
            @items = @items.where{full_name.like_any sanitized_names}
          end
        end

        with.keyword :name do |names|
          names.each do |name|
            sanitized_names = to_string_array(name, append_wildcard: true)
            @items = @items.where{(username.like_any sanitized_names) | \
                                  (first_name.like_any sanitized_names) | \
                                  (last_name.like_any sanitized_names) | \
                                  (full_name.like_any sanitized_names)}
          end
        end

        with.keyword :id do |ids|
          ids.each do |id|
            sanitized_ids = to_string_array(id)
            @items = @items.where{(openstax_uid.eq_any sanitized_ids)}
          end
        end

        with.keyword :any do |terms|
          terms.each do |term|
            sanitized_names = to_string_array(term, append_wildcard: true)
            sanitized_ids = to_string_array(term)

            @items = @items.where{(username.like_any sanitized_names) | \
                                  (first_name.like_any sanitized_names) | \
                                  (last_name.like_any sanitized_names) | \
                                  (full_name.like_any sanitized_names) | \
                                  (openstax_uid.eq_any sanitized_ids)}
          end
        end
      }

      self.sortable_fields_map = {
        'username' => :username,
        'first_name' => :first_name,
        'last_name' => :last_name,
        'full_name' => :full_name,
        'id' => :openstax_uid
      }
    end
  end
end
