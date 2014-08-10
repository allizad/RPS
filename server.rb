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
  
  @my_turn_rounds = RPS.dbi.my_turn_rounds(session['RPS_session'])
  @game_id_of_my_turn_rounds = @my_turn_rounds.map {|round| round.game_id}
  @my_turn_data = []
  @game_id_of_my_turn_rounds.each do |game_id|
    hash = {}
    hash[:game_id] = game_id
    hash[:opponent] = RPS.dbi.opponent_name(session['RPS_session'], game_id)
    @my_turn_data << hash
  end

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
  game_object = RPS.dbi.start_game(session['RPS_session'], params[:username])

  redirect to "/game/#{params[:username]}/#{game_object.game_id}"
end
 
get '/game/:username/:game_id' do
  
  @game_rounds = RPS.dbi.get_all_rounds_for_game_id(params[:game_id])
  @active_round = @game_rounds.find {|r| r.active?}
  @game_rounds.delete(@active_round)

  @player1_name = RPS.dbi.get_player1_name(params[:game_id])['player1']
  @player2_name = RPS.dbi.get_player2_name(params[:game_id])['player2']
 
  if !@active_round
    @active_round = RPS.dbi.start_round(params[:game_id].to_i, @player1_name, @player2_name)
  else
    @active_round
  end
 
  erb :game
end

post '/game/:username/:game_id/:round_id/:move' do
  @player1 = RPS.dbi.player_1?(session['RPS_session'], params[:game_id])
#if im player one:
  if @player1
    RPS.dbi.player1_move(params[:round_id], params[:move])
    last_round = RPS.dbi.get_all_rounds_for_game_id(params[:game_id]).last
    if last_round.round_over?
      RPS.dbi.insert_round_winner(last_round.winner, last_round.round_id)
      round_winner_usernames = RPS.dbi.complete_rounds(params[:game_id])
      opponent_name = RPS.dbi.opponent_name(session['RPS_session'], params[:game_id])
      if round_winner_usernames.count(session['RPS_session']) > 2
        RPS.dbi.update_game_winner(session['RPS_session'], params[:game_id])
      elsif round_winner_usernames.count(opponent_name) > 2
        RPS.dbi.update_game_winner(opponent_name, params[:game_id])
      end
    end
  elsif !@player1
    RPS.dbi.player2_move(params[:round_id], params[:move])
    last_round = RPS.dbi.get_all_rounds_for_game_id(params[:game_id]).last
    if last_round.round_over?
      RPS.dbi.insert_round_winner(last_round.winner, last_round.round_id)
      round_winner_usernames = RPS.dbi.complete_rounds(params[:game_id])
      opponent_name = RPS.dbi.opponent_name(session['RPS_session'], params[:game_id])
      if round_winner_usernames.count(session['RPS_session']) > 2
        RPS.dbi.update_game_winner(session['RPS_session'], params[:game_id])
      elsif round_winner_usernames.count(opponent_name) > 2
        RPS.dbi.update_game_winner(opponent_name, params[:game_id])
      end
    end
  end
  #if game winner, redirect to game-over page
  #else..
  redirect to "/game/#{params[:username]}/#{params[:game_id]}"
end
 
get '/game' do
 
erb :game
end
 
 
get '/signout' do
 session.clear
 redirect to '/'
end
