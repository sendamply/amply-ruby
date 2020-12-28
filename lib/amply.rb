require_relative 'amply/version'
require_relative 'amply/exceptions'
require_relative 'amply/client'
require_relative 'amply/email'

module Amply
  class << self
    def set_access_token(token)
      Client.set_access_token(token)
    end
  end
end
