module Amply
  module Helpers
    class EmailAddress
      class << self
        def create(data)
          if data.is_a?(Array)
            return data.reject { |el| el.nil? || el == '' }
              .map { |el| self.class.create(el) }
          end

          if data.is_a?(EmailAddress)
            return data
          end

          self.class.create(data)
        end
      end

      def initialize(data)
        if data.is_a?(String)
          data = from_string(data)
        end

        unless data.is_a?(Hash)
          raise 'Expecting hash or string for email address data'
        end

        name = data[:name] || data['name']
        email = data[:email] || data['email']

        set_name(name)
        set_email(email)
      end

      def to_json
        json = { email: @email }

        unless @name.nil?
          json[:name] = @name
        end

        json
      end

      private

      def set_name(name)
        return if name.nil?

        unless name.is_a?(String)
          raise 'String expected for `name`'
        end

        @name = name
      end

      def set_email(email)
        if email.nil?
          raise 'Must provide `email`'
        end

        unless email.is_a?(String)
          raise 'String expected for `email`'
        end

        @email = email
      end

      def from_string(data)
        if data.index('<').nil?
          return { name: nil, email: data }
        end

        name, email = data.split('<')

        name.strip!
        email.gsub!('>', '')
        email.strip!

        { name: name, email: email }
      end
    end
  end
end
