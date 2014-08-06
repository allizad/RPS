require 'pg'
require 'pry-byebug'

module RPS
  class DBI
    def initialize
      @db = PG.connect(host: 'localhost', dbname: 'RPS')
      build_tables
    end

    def build_tables
      @db.exec(%q[
        CREATE TABLE IF NOT EXISTS users(
          user_id serial NOT NULL PRIMARY KEY,
          username text,
          password_digest text,
          created_at timestamp NOT NULL DEFAULT current_timestamp
          )])
      @db.exec(%q[
        CREATE TABLE IF NOT EXISTS games(
          game_id serial NOT NULL PRIMARY KEY,
          p1_id integer,
          p2_id integer,
          game_winner integer
          )])
      @db.exec(%q[
        CREATE TABLE IF NOT EXISTS rounds(
          round_id serial NOT NULL PRIMARY KEY,
          game_id integer,
          p1_move text,
          p2_move text,
          round_winner integer
          )])
    end
      # USERS
      # GAMES
      # ROUNDS
    end
  end
end