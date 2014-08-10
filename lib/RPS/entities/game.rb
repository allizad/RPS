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

    # def game_over?
      
    # end

    def game_winner
      
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

    # def round_over?
    #   if @p1_move == nil || @p2_move == nil
    #     false
    #   else
    #     true
    #   end
    # end

    def move_for(player)
      if player == player1
        p1_move
      elsif player == player2
        p2_move
      end
    end

    def winner(p1_move, p2_move)
      if p1_move == p2_move
        "tie"
      elsif p1_move == "rock"
        if p2_move == "paper"
          "player2"
        elsif p2_move == "scissors"
          "player1"
        end
      elsif p1_move == "paper"
        if p2_move == "rock"
          "player1"
        elsif p2_move == "scissors"
          "player1"
        end
      elsif p1_move == "scissors"
        if p2_move == "paper"
          "player1"
        elsif p2_move == "rock"
          "player2"
        end
      end
    end


  end
end
