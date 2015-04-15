module OpenStax
  module Accounts
    module Api
      module V1
        class UnclaimedAccountRepresenter < Roar::Decorator
          include Roar::JSON

          property :id,
                   type: Integer,
                   readable: true,
                   writeable: true
        end
      end
    end
  end
end
