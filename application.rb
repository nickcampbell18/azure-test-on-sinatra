require 'dotenv'
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
Dotenv.load

class Tester < Sinatra::Base

  RESOURCE = 'https://graph.windows.net'
  REDIRECT_URI = 'http://localhost:4848/consume'

  def client
    OAuth2::Client.new                ENV['CLIENT_ID'],
                                      ENV['CLIENT_SECRET'],
                       site:          ENV['LOGIN_SITE'],
                       token_url:     ENV['TOKEN_URL'],
                       authorize_url: ENV['AUTHORIZE_URL']

  end

  def auth_code
    client.auth_code
  end

  get '/' do
    '<a href="/login">Login</a>'
  end

  get '/login' do
    redirect auth_code.authorize_url redirect_uri: REDIRECT_URI,
                                     resource:     RESOURCE
  end

  get '/consume' do
    if params[:code]
      token = auth_code.get_token params[:code], redirect_uri: REDIRECT_URI
      token.get('https://graph.windows.net/me?api-version=2013-04-05')
    end
    %Q{<pre style="max-width:100%;word-wrap:break-word;white-space:pre-line;">
      Logged in with token:

        #{token.token}
    </pre>}
  end

end