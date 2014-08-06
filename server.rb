require 'sinatra'
require 'rack-flash'
require_relative 'lib/RPS.rb'

set :sessions, true
use Rack::Flash
set :bind, '0.0.0.0'

# main page - sign in or sign up
get '/' do
 if session['RPS']
   @user = RPS.dbi.get_user_by_username(session['RPS'])
 end
 
  erb :index
end

# Sign in
post '/summary' do
  # checks for user and password, if passes - goes to summary

  if params['username'].empty? || params['password'].empty?
    flash[:alert1] = "Please fill out all input fields."
    redirect to '/'
  end

  @user = RPS.dbi.get_user_by_username(params['username'])
  if @user && @user.has_password?(params['password'])
    session['RPS'] = @user.username
    redirect to '/summary'
  else   # if it doesn't pass, alert issue
    flash[:alert1] = "That is not the correct password, please try again."
    redirect to '/'
  end
  # goes to datanbase to CHECK FOR USER
  # returns username

  erb :summary
end

#Register to play - link in it to start a new game and see summaries
# FIX ALL METHODS for interpolation
post '/registration' do
  # PARAMS
  # adds a new user - INITIALIZES a user into the database with proper number of arguments
  # goes to the registration page with information
<<<<<<< HEAD
  redirect to "/registration/#{params['username']}"
=======

if params['username'].empty? || params['password'].empty? || params['password_confirmation'].empty?
    flash[:alert2] = "Please fill out all input fields."
    redirect to '/'
  end

  if RPS.dbi.username_exists?(params['username'])
    flash[:alert2] = "Username already exists, choose another username."
    redirect to '/'
  elsif params['password'] == params['password_confirmation']
    @user = RPS::User.new(params['username'])
    @user.update_password(params['password'])
    RPS.dbi.register_user(@user)
    session['RPS'] = @user.username
  else
    flash[:alert2] = "Passwords don't match.  Please try again."
    redirect to '/'
  end

  erb :registration

>>>>>>> 439a868369d521cb848c3888bfef0eccbaba253a
end

# on registration page - need to get to summary OR startplaying
get '/summary' do
  #*************not sure if we need this anymore******
  # a lot happening here:
    # needs to access the game id's that belong to this unique user.
    # organizes that data based on status of game - if there's a winner or not on the game id
    # grabs round ids that match game ids to populate numerical status of where the game is at (0/0 rounds, 2/4, etc)

  erb :summary
end

get '/start-game' do
  # choose an opponent
  erb :start_game
end

# from start game, you create a new game
post '/game' do

  erb :game
end

# some sort of post method for when a player makes a move in the game page

get '/game' do
  erb :game
end

<<<<<<< HEAD
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
=======
get '/signout' do
 session.clear
 redirect to '/'
end
>>>>>>> 439a868369d521cb848c3888bfef0eccbaba253a
