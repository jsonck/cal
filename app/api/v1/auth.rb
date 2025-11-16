module V1
  class Auth < Grape::API
    namespace :auth do
      desc 'Check authentication status'
      get :status do
        { authenticated: false, message: 'Please authenticate with Google' }
      end

      desc 'Get OAuth URL'
      get :oauth_url do
        { url: '/auth/google_oauth2' }
      end
    end
  end
end
