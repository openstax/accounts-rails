module Api
  class ApplicationUsersController < DummyController
    def index
      dummy(:index)
    end

    def updates
      dummy(:updates)
    end

    def updated
      dummy(:updated)
    end
  end
end
