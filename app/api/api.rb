# Load V1 API modules
require_relative 'v1/base'

class API < Grape::API
  prefix 'api'

  mount V1::Base
end
