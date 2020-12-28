require 'json'

module Amply
  module Exceptions
    class ValidationException < StandardError
      attr_reader :errors

      def initialize(response)
        @errors = JSON.parse(response.body, symbolize_names: true)[:errors]

        super
      end

      def message
        'A validation error occurred while making an API request'
      end
    end
  end
end
