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

    def username_exists?(username)
      result = @db.exec(%Q[
        SELECT * FROM users WHERE username = '#{username}';
      ])

      if result.count > 0
        true
      else
        false
      end
    end

    def build_user(data)
      RPS::User.new(data['username'], data['password_digest'])
    end

    def opponent_list(session_username)
      result = @db.exec_params(%Q[
        SELECT username FROM users WHERE username != $1;
      ],[session_username])
      return result
    end

    def start_game(player1, player2)
      @db.exec_params(%q[
      INSERT INTO games (player1, player2)
      VALUES ($1, $2);
      ], [player1.user_id, player2.user_id])
    end

    def start_round(game_id, p1_move)
      @db.exec_params(%q[
        INSERT INTO rounds (game_id, p1_move)
        VALUES ($1, $2);
        ], [game_id, p1_move])
    end

    def finish_round(game_id, p2_move)
      @db.exec_params(%q[
        INSERT INTO rounds (game_id, p2_move)
        VALUES ($1, $2);
        ], [game_id, p2_move])  
    end

    def play_move(move)
      
    end

    def game_over?(game_id, player1, player2)
      result = @db.exec(%Q[
        SELECT round_winner FROM rounds WHERE game_id = '#{game_id}';
      ])

      if result.count(player1.user_id) > 2
        return true
      elsif result.count(player2.user_id) > 2
        return true
      end
    end
  end
# singleton creation
  def self.dbi
    @__db_instance ||= DBI.new
  end
end



