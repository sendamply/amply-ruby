module Amply
  module Exceptions
    class APIException < StandardError
      attr_reader :status, :text

      def initialize(response)
        @status = response.code.to_i
        @text = response.message

        super
      end

      def message
        'An error occurred while making an API request'
      end
    end
  end
end
