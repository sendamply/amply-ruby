require 'json'

module Amply
  module Exceptions
    class ResourceNotFoundException < StandardError
      attr_reader :errors

      def initialize(response)
        @errors = JSON.parse(response.body, symbolize_names: true)[:errors]

        super
      end

      def message
        'The resource was not found while making an API request'
      end
    end
  end
end
