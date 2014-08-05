require 'sinatra'
require_relative 'lib/RPS.rb'

set :sessions, true
set :bind, '0.0.0.0'

# main page - sign in or sign up
get '/' do
 if session['RPS']
   @user = DBI.dbi.get_user_by_username(session['RPS'])
 end
 
  erb :index
end

# Sign in
get '/summary/:username' do
  # checks for user and password, if passes - goes to summary
  erb :summary
  # if it doesn't pass, alert issue
end

#Register to play - link in it to start a new game and see summaries
# FIX ALL METHODS for interpolation
post '/registration' do
  # adds a new user
  # goes to the registration page with information
  redirect to '/registration/#{params['username']}'
end

# on registration page - need to get to summary OR startplaying
get '/summary/:username' do
  erb :summary
end

get '/start-game' do
  erb :start_game
end

# from start game, you create a new game
post '/game' do
  redirect to '/game/:game_id'
end

get '/game/:game_id' do
  erb :game
end

# post '/signup' do
#   user = DBI::User.new(params['username'])
#   user.update_password(params['password'])
#   DBI.dbi.persist_user(user)

#   redirect to '/'
#   erb :signup
# end

# get '/signin' do
#   erb :signin
# end

# post '/signin' do
#   user = DBI.dbi.get_user_by_username(params['username'])
#     if user && user.has_password?(params['password'])
#       session['RPS'] = user.username
#       redirect to '/'
#     else
#       "THAT'S NOT THE RIGHT PASSWORD!!!!"
#     end
# end

# get '/signout' do
#  session.clear
#  redirect to '/'
# end