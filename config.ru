require 'dashing'
require 'dotenv'

# Load environment variables using Dotenv. If a .env file exists, it will
# set environment variables from that file (useful for dev environments)
Dotenv.load

configure do
  set :auth_token, ENV['DASHING_AUTH_TOKEN'] || 'YOUR_AUTH_TOKEN'
  set :default_dashboard, 'dashpi'

  helpers do
    def protected!
     # Put any authentication code you want in here.
     # This method is run before accessing any resource.
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application