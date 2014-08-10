module RPS
  class Game

    attr_reader :game_id, :player1, :player2, :game_winner
    
    # game is initalized with two players
    def initialize(data = {})
      @game_id = data['game_id']
      @player1 = data['player1']
      @player2 = data['player2']
      @game_winner = data['game_winner']
    end

    def self.find(game_id)
      RPS.dbi.find_game_by_id(game_id)
    end

    def game_over?
      round_winner_usernames = RPS.dbi.complete_rounds(game_id)
      round_winner_usernames.count(player1) > 2 || round_winner_usernames.count(player2) > 2
    end

    def update_game_winner
      round_winner_usernames = RPS.dbi.complete_rounds(game_id)
      if round_winner_usernames.count(player1) > 2
        RPS.dbi.update_game_winner(player1, game_id)
        @game_winner = player1
      elsif round_winner_usernames.count(player2) > 2
        RPS.dbi.update_game_winner(player2, game_id)
        @game_winner = player2
      end
    end

    def self.past_games(username)
      RPS.dbi.get_past_games_for_username(username)
    end

    def game_id_and_opponent_hash(username)
      hash = {}
        if username == player1
          hash[:opponent] = player2
          hash[:game_id] = game_id
        elsif username == player2
          hash[:opponent] = player1
          hash[:game_id] = game_id
        end
      return hash
    end

  end

  class Round

    attr_reader :round_id, :player1, :player2, :game_id, :p1_move, :p2_move, :round_winner

    def initialize(data = {})
      @round_id = data['round_id']
      @game_id = data['game_id']
      @player1 = data['player1']
      @player2 = data['player2']
      @p1_move = data['p1_move']
      @p2_move = data['p2_move']
      @round_winner = data['round_winner']
    end

    def active?
      @p1_move == nil || @p2_move == nil
    end

    def move_for(player)
      if player == player1
        p1_move
      elsif player == player2
        p2_move
      end
    end

    def winner
      if p1_move == p2_move
        "tie"
      elsif p1_move == "rock"
        if p2_move == "paper"
          return player2
        elsif p2_move == "scissors"
          return player1
        end
      elsif p1_move == "paper"
        if p2_move == "rock"
          return player1
        elsif p2_move == "scissors"
          return player2
        end
      elsif p1_move == "scissors"
        if p2_move == "paper"
          return player1
        elsif p2_move == "rock"
          return player2
        end
      end
    end

    def round_over?
      p1_move != nil && p2_move != nil
    end

    def self.find(round_id)
      RPS.dbi.find_round_by_id(round_id)
    end

    def record_move(player, move)
      if player == player1
        RPS.dbi.player1_move(round_id, move)
        @p1_move = move
      elsif player == player2
        RPS.dbi.player2_move(round_id, move)
        @p2_move = move
      end
    end

    def update_round_winner
      RPS.dbi.insert_round_winner(winner, round_id)
      @round_winner = winner
    end

    def self.my_turn_rounds(username)
      RPS.dbi.my_turn_rounds(username)
    end

    def self.not_my_turn_rounds(username)
      RPS.dbi.not_my_turn_rounds(username)
    end

    # def opponent_name(username)
    #   if username == player1
    #     return player2
    #   elsif username == player2
    #     return player1
    #   end
    # end

    def game_id_and_opponent_hash(username)
        hash = {}
        if username == player1
          hash[:opponent] = player2
          hash[:game_id] = game_id
        elsif username == player2
          hash[:opponent] = player1
          hash[:game_id] = game_id
        end
        return hash
    end


  end
end
