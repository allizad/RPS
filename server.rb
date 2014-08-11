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

  @my_turn_round_objects = RPS::Round.my_turn_rounds(session['RPS_session'])
  @not_my_turn_round_objects = RPS::Round.not_my_turn_rounds(session['RPS_session'])
  @past_game_objects = RPS::Game.past_games(session['RPS_session'])

  @my_turn_data = @my_turn_round_objects.map do |round|
    round.game_id_and_opponent_hash(session['RPS_session'])
  end

  @not_my_turn_data = @not_my_turn_round_objects.map do |round|
    round.game_id_and_opponent_hash(session['RPS_session'])
  end

  @past_game_data = @past_game_objects.map do |game|
    game.game_id_and_opponent_hash(session['RPS_session'])
  end

  @win_hash = RPS.dbi.win_count(@user.username)
  @lose_hash = RPS.dbi.lose_count(@user.username)
  # binding.pry
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

  if @current_game.game_over?
    erb :game_over
  else
    erb :game
  end

end

post '/game/:username/:game_id/:round_id/:move' do

  @round = RPS::Round.find(params[:round_id])
  @game = RPS::Game.find(params[:game_id])

  @round.record_move(session['RPS_session'],params[:move])

  if @round.round_over?
    @round.update_round_winner
    if @game.game_over?
      @game.update_game_winner
    end
  end

  redirect to "/game/#{params[:username]}/#{params[:game_id]}"

end
 
get '/game' do
  erb :game
end
 
 
post '/signout' do
 session.clear
 redirect to '/'
end
