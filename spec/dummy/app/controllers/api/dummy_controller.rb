module Api
  class DummyController < ApplicationController
    class << self; attr_accessor :last_action, :last_params, :last_json end

    def dummy(action_name = :dummy)
      self.class.last_action = action_name
      self.class.last_params = params.permit!.to_h
      self.class.last_json = ActiveSupport::JSON.decode(request.body.read) rescue nil
      render json: { head: :no_content }
    end
  end
end
