module OpenStax::Connect::Dev
  class UsersSearch

    lev_handler transaction: :no_transaction
    
    paramify :search do
      attribute :search_type, type: String
      validates :search_type, presence: true,
                              inclusion: { in: %w(Name Username Any),
                                           message: "is not valid" }

      attribute :search_terms, type: String
      validates :search_terms, presence: true                               
    end

    uses_routine OpenStax::Connect::SearchUsers, 
                 as: :search_users,
                 translations: { outputs: {type: :verbatim} }

  protected

    def authorized?
      !Rails.env.production? || caller.is_administrator?
    end

    def handle
      terms = search_params.search_terms
      type = search_params.search_type

      run(:search_users, terms, type.downcase.to_sym)
    end

  end
end
