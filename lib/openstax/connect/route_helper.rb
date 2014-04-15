require 'singleton'

module OpenStax
  module Connect
    class RouteHelper
      
      include Singleton

      # Registers a path against a canonical name.  An optional
      # block can be provided to give the stubbed path
      def self.register_path(canonical_name, path, &block)
        instance.paths[canonical_name] = path
        if block.present? && OpenStax::Connect.configuration.enable_stubbing?
          instance.stubbed_paths[canonical_name] = block.call
        end
      end

      def self.get_path(canonical_name)
        OpenStax::Connect.configuration.enable_stubbing? ?
          instance.stubbed_paths[canonical_name] :
          instance.paths[canonical_name]
      end

      def initialize
        self.paths = {}
        self.stubbed_paths = {}
      end

      attr_accessor :paths
      attr_accessor :stubbed_paths

    end
  end
end