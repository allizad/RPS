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

    def register_user(user)
        @db.exec_params(%q[
        INSERT INTO users (username, password_digest)
        VALUES ($1, $2);
        ], [user.username, user.password_digest])
    end

    def get_user_by_username(username)
      result = @db.exec(%Q[
        SELECT * FROM users WHERE username = '#{username}';
      ])

      user_data = result.first

      if user_data
        build_user(user_data)
      else
        nil
      end

    end

    def build_user(data)
      Sesh::User.new(data['username'], data['password_digest'])
    end



  end
end