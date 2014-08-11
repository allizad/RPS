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
          player1 text,
          player2 text,
          p1_move text,
          p2_move text,
          round_winner text
          )])
    end

    #### USERS ####
 
    def register_user(user)
        @db.exec_params(%q[
        INSERT INTO users (username, password_digest)
        VALUES ($1, $2);
        ], [user.username, user.password_digest])
    end
 
    def get_user_by_username(username)
      result = @db.exec(%Q[
        SELECT *
        FROM users
        WHERE username = '#{username}';
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
        SELECT *
        FROM users
        WHERE username = '#{username}';
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
        SELECT username
        FROM users
        WHERE username != $1;
      ],[session_username])
      return result
    end

    #### GAMES ####

    def build_game(data)
      RPS::Game.new(data)
    end

    def get_game_by_id(game_id)
      result = @db.exec_params(%Q[
        SELECT * FROM games WHERE game_id = $1;
      ], [game_id])
      game_object = build_game(result.first)
      game_object       
    end
 
    def start_game(player1_username, player2_username)
      result = @db.exec_params(%q[
      INSERT INTO games (player1, player2)
      VALUES ($1, $2)
      RETURNING *;
      ], [player1_username, player2_username])
 
      # return result.first
      build_game(result.first)
    end

    def get_active_games_for_username(username)
      result = @db.exec_params(%q[
        SELECT *
        FROM games
        WHERE player1 = $1
        OR player2 = $1
        AND game_winner IS NULL;
        ], [username])

      result.map {|row| build_game(row) }
    end

    def get_past_games_for_username(username)
      result = @db.exec_params(%q[
        SELECT *
        FROM games
        WHERE player1 = $1
        OR player2 = $1
        AND game_winner IS NOT NULL;
        ], [username])

      result.map {|row| build_game(row)}
    end

    def get_player1_name(game_id)
      result = @db.exec_params(%q[
        SELECT player1
        FROM games
        WHERE game_id = $1;
        ], [game_id])
      result.first
    end
 
    def get_player2_name(game_id)
      result = @db.exec_params(%q[
        SELECT player2
        FROM games
        WHERE game_id = $1;
        ], [game_id])
      result.first
    end


    def game_over?(game_id, player1, player2)
      result = @db.exec(%Q[
        SELECT round_winner
        FROM rounds
        WHERE game_id = $1;
      ], [game_id])

      if result.count(player1.user_id) > 2
        return true
      elsif result.count(player2.user_id) > 2
        return true
      end
    end

    def complete_rounds(game_id)
      result = @db.exec_params(%q[
        SELECT round_winner
        FROM rounds
        WHERE game_id = $1;
        ], [game_id])
      
      result.map{|x| x['round_winner']}

    end

    def find_game_by_id(game_id)
      result = @db.exec_params(%q[
        SELECT *
        FROM games
        WHERE game_id = $1;
        ], [game_id])

      build_game(result.first)
    end

    def update_game_winner(game_winner, game_id)
        @db.exec_params(%q[
        UPDATE games
        SET game_winner = $1
        WHERE game_id = $2;
        ], [game_winner, game_id])
    end


    #### ROUNDS ####

    def build_round(data)
      RPS::Round.new(data)
    end
 
    def get_all_rounds_for_game_id(game_id)
        result = @db.exec_params(%q[
        SELECT *
        FROM rounds
        WHERE game_id = $1;
        ], [game_id])
 
        result.map {|row| build_round(row)}
    end

    def find_round_by_id(round_id)
      result = @db.exec_params(%q[
        SELECT *
        FROM rounds
        WHERE round_id = $1;
        ], [round_id])

      build_round(result.first)
    end
 
    def start_round(game_id, player1, player2)
      result = @db.exec_params(%q[
        INSERT INTO rounds (game_id, player1, player2)
        VALUES ($1, $2, $3)
        RETURNING *;
        ], [game_id, player1, player2])
 
      build_round(result.first)
    end
 
    def player1_move(round_id, move)
      @db.exec_params(%q[
        UPDATE rounds
        SET p1_move = $2
        WHERE round_id = $1;
        ], [round_id, move])
    end
 
    def player2_move(round_id, move)
      @db.exec_params(%q[
        UPDATE rounds
        SET p2_move = $2
        WHERE round_id = $1;
        ], [round_id, move])
    end
 
    def player_1?(username, game_id)
      result = @db.exec_params(%q[
        SELECT player1
        FROM games
        WHERE game_id = $1;
        ], [game_id])
      if result.first['player1'] == username
        true
      else
        false
      end
    end

    def my_turn_rounds(username)
      result = @db.exec_params(%q[
        SELECT * FROM rounds
        WHERE player1 = $1 AND p1_move IS NULL
        OR player2 = $1 AND p2_move IS NULL;
        ], [username])

      result.map {|row| build_round(row)}
    end

    def not_my_turn_rounds(username)
      result = @db.exec_params(%q[
        SELECT * FROM rounds
        WHERE player1 = $1 AND p2_move IS NULL
        OR player2 = $1 AND p1_move IS NULL;
        ], [username])

      result.map {|row| build_round(row)}
    end

    def insert_round_winner(winner, round_id)
      @db.exec_params(%q[
        UPDATE rounds
        SET round_winner = $1
        WHERE round_id = $2;
        ], [winner, round_id])
    end

    def opponent_name(username, game_id)
      result = @db.exec_params(%q[
        SELECT *
        FROM games
        WHERE game_id = $1;
        ], [game_id])
      if result.first['player1'] == username
        result.first['player2']
      else
        result.first['player1']
      end
    end


  end


# singleton creation
  def self.dbi
    @__db_instance ||= DBI.new
  end
end
