require_relative './helpers/email'

module Amply
  class Email
    class << self
      def create(data)
        parsed_data = Helpers::Email.new(data).parsed_data
        Client.post('/email', parsed_data)
      end
    end
  end
end
