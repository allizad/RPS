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

# choose an opponent
get '/new-game' do
  @opponents = RPS.dbi.opponent_list(session['RPS_session'])

  erb :new_game
end

# from new game, you create a game with opponent
get '/game/:username' do
  # @opponent_username = params[:username]
  @game = RPS.dbi.start_game(session['RPS_session'], params[:username])

  redirect to "/game/#{params[:username]}/#{@game}"
end

get '/game/:username/:game_id' do
  # method that automatically check the dbi to update any info => return a @variable 
  @game_rounds = RPS.dbi.get_all_rounds_for_game_id(params[:game_id])  

  @round = RPS.dbi.start_round(params[:game_id])

  redirect to "/game/#{params[:username]}/#{params[:game_id]}/#{@round}"
end

get '/game/:username/:game_id/:round_id' do

  erb :game
end

get '/move/:move' do
  @move = params[:move]


  redirect to '/game'
end

get '/game' do

erb :game
end


get '/signout' do
 session.clear
 redirect to '/'
end
