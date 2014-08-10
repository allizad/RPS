require 'sinatra'
require 'rack-flash'
require_relative 'lib/RPS.rb'

require 'pry-byebug'

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

  # array of active game objects
  # @active_games = RPS.dbi.get_active_games_for_username(session['RPS_session'])
  
  @my_turn_rounds = RPS.dbi.my_turn_rounds(session['RPS_session'])

  @game_id_of_my_turn_rounds = @my_turn_rounds.map {|round| round.game_id}

  @my_turn_data = []

  @game_id_of_my_turn_rounds.each do |game_id|
    hash = {}
    hash[:game_id] = game_id
    hash[:opponent] = RPS.dbi.opponent_name(session['RPS_session'], game_id)
    @my_turn_data << hash
  end

  # binding.pry

  @past_games = RPS.dbi.get_past_games_for_username(session['RPS_session'])

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
post '/game/:username' do
  # @opponent_username = params[:username]
  # game_object = RPS::Game.new(session['RPS_session'], params[:username])
  game_object = RPS.dbi.start_game(session['RPS_session'], params[:username])
  # binding.pry

  redirect to "/game/#{params[:username]}/#{game_object.game_id}"
end
 
# get '/game/:username/:game_id' do
#   # method that automatically check the dbi to update any info => return a @variable 
#   round = RPS.dbi.start_round(params[:game_id].to_i)
 
#   redirect to "/game/#{params[:username]}/#{params[:game_id]}/#{round}"
# end

get '/game/:username/:game_id' do
  @current_game = RPS.dbi.get_game_by_id(params[:game_id])
  # this code is for creating the table in :game
  # uses game id to grab all of the rounds for this game
  @game_rounds = RPS.dbi.get_all_rounds_for_game_id(params[:game_id])
  # determines which out of those rounds is active
  @active_round = @game_rounds.find {|r| r.active?}
  # deletes that active round so moves don't display until the round is over
  @game_rounds.delete(@active_round)

  if !@active_round
    @active_round = RPS.dbi.start_round(params[:game_id].to_i, @current_game.player1, @current_game.player2)
  end

  @user_name = session['RPS_session']
  @user_move = @active_round.move_for(@user_name)

  erb :game
end



post '/game/:username/:game_id/:round_id/:move' do
  # @move = params[:move]

  @player1 = RPS.dbi.player_1?(session['RPS_session'], params[:game_id])
#if im player one:
  if @player1
    RPS.dbi.player1_move(params[:round_id], params[:move])
  else
    RPS.dbi.player2_move(params[:round_id], params[:move])
    #determine winner
  end
#player_2 move

  # create values for opponent username, game id, round id 
  # start a new round
 
  redirect to "/game/#{params[:username]}/#{params[:game_id]}"
end
 
get '/game' do
 
erb :game
end
 
 
get '/signout' do
 session.clear
 redirect to '/'
end
