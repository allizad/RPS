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
          player1 text,
          player2 text,
          game_winner text
          )])
      @db.exec(%q[
        CREATE TABLE IF NOT EXISTS rounds(
          round_id serial NOT NULL PRIMARY KEY,
          game_id integer,
          p1_move text,
          p2_move text,
          round_winner text
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

    def build_game(data)
      RPS::Game.new(data['player1'], data['player2'])
    end

    def start_game(player1_username, player2_username)
      result = @db.exec_params(%q[
      INSERT INTO games (player1, player2)
      VALUES ($1, $2)
      RETURNING game_id;
      ], [player1_username, player2_username])

      result.first['game_id']
    end

    def has_rounds?(game_id)
      result = @db.exec(%q[
        SELECT round_id FROM rounds WHERE game_id = '#{game_id}'
        ])
      if result.first == nil
        return false
      else
        return true
      end
    end

    def get_active_round(game_id)
      result = @db.exec(%q[
        SELECT round_winner FROM rounds WHERE game_id = #{game_id};
        ])
    end

    def build_round(data)
      RPS::Round.new(data)
    end

    def get_all_rounds_for_game_id(game_id)
        result = @db.exec_params(%q[
        SELECT * FROM rounds WHERE game_id = $1;
        ], [game_id])

        result.map {|row| build_round(row)}
    end

    def start_round(game_id)
      result = @db.exec_params(%q[
        INSERT INTO rounds (game_id)
        VALUES ($1)
        RETURNING *;
        ], [game_id])

      build_round(result.first)
    end

    def player1_move(round_id, move)
      @db.exec_params(%q[
        UPDATE rounds
        SET p1_move = $2
        WHERE round_id = $1;
        ], [round_id, move])
    end

    def player2_move(round_id, game_id, move)
      @db.exec_params(%q[
        INSERT INTO rounds (round_id, game_id, move)
        VALUES ($1, $2, $3);
        ], [round_id, game_id, move])
    end 

    def player_1?()
      @db.exec_params(%q[
        SELECT player1 FROM rounds WHERE game_id = 
        ])
      #return true if nothing in player 1 spot
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



