require 'net/http'
require 'json'

module Amply
  class Client
    DEFAULT_HEADERS = {
      Accept: 'application/json',
      'Content-Type': 'application/json'
    }

    class << self
      @@access_token = ''
      @@url          = 'https://sendamply.com/api/v1'

      def set_access_token(token)
        @@access_token = token
      end

      def post(path, body, options = {})
        uri = URI("#{@@url}#{path}")
        headers = [
          DEFAULT_HEADERS,
          options[:headers] || {},
          auth_header
        ].inject(&:merge)


        resp = Net::HTTP.post(uri, body.to_json, headers)
        parse_response(resp)
      end

      def parse_response(resp)
        code = resp.code.to_i

        if [301, 302].include?(code)
          return resp['location']
        elsif [401, 403].include?(code)
          raise Exceptions::APIException, resp
        elsif code == 404
          raise Exceptions::ResourcNotFoundException, resp
        elsif code == 422
          raise Exceptions::ValidationException, resp
        elsif code < 200 || code >= 300
          raise Exceptions::APIException, resp
        end

        JSON.parse(resp.body, symbolize_names: true)
      end

      def auth_header
        { Authorization: "Bearer #{@@access_token}" }
      end
    end
  end
end
