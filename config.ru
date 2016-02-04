require 'dashing'

configure do
  set :auth_token, 'f467e9cf-0794-40bc-ba12-34ac68b9d391'

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