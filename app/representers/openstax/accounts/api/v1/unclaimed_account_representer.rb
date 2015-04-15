module OpenStax
  module Accounts
    module Api
      module V1
        class UnclaimedAccountRepresenter < Roar::Decorator
          include Roar::Representer::JSON

          property :id,
                   type: Integer,
                   readable: true,
                   writeable: false
        end
      end
    end
  end
end
