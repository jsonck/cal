require_relative 'auth'
require_relative 'users'

module V1
  class Base < Grape::API
    version 'v1', using: :path
    format :json

    mount V1::Auth
    mount V1::Users
  end
end
