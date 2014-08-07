require 'sinatra'
require 'rack-flash'
require_relative 'lib/RPS.rb'

set :sessions, true
use Rack::Flash
set :bind, '0.0.0.0'

# main page - sign in or register
get '/' do
 if session['RPS_session']
   @user = RPS.dbi.get_user_by_username(session['RPS_session'])
 end
 
  erb :index
end

get '/summary' do
  @user = RPS.dbi.get_user_by_username(session['RPS_session'])
  erb :summary
end

# Sign in - checks for user and password, goes to summary
post '/signin' do
  sign_in = RPS::SignIn.run(params)

  if sign_in[:success?]
    session['RPS_session'] = sign_in[:session_id]
    redirect to '/summary'
  else
    flash[:alert1] = sign_in[:error]
    redirect to '/'
  end
end

#Register to play - goes straight to summary page
post '/register' do
  register = RPS::Register.run(params)

  if register[:success?]
    session['RPS_session'] = register[:session_id]
    redirect to '/summary'
  else
    flash[:alert2] = register[:error]
    redirect to '/'
  end
end

get '/new-game' do
  # choose an opponent
  erb :new_game
end

get '/game' do
  erb :game
end

# from start game, you create a new game
post '/game' do
  erb :game
end

get '/signout' do
 session.clear
 redirect to '/'
end
