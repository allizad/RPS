 module RPS
  class Game

    attr_reader :player1, :player2
    
    # game is initalized with two players
    def initialize(player1, player2)
      @player1 = player1
      @player2 = player2
    end

    def game_over?
      
    end

    def game_winner
      
    end
  end

  class Round

    attr_reader :p1_move, :p1_move, :round_winner

    def initialize(p1_move, p2_move)
      @p1_move = p1_move
      @p2_move = p2_move
      # return winner
    end

    def round_over?
      if @p1_move == nil || @p2_move == nil
        false
      else
        true
      end
    end

    def winner
      if !round_over?
        return nil
      elsif @p1_move == @p2_move
        return 'tie'
      elsif @p1_move == "rock"
        if @p2_move == "paper"
          return "player2"
        elsif @p2_move == "scissors"
          return "player1"
        end
      elsif @p1_move == "paper"
        if @p2_move == "rock"
          return "player1"
        elsif @p2_move == "scissors"
          return "player1"
        end
      elsif @p1_move == "scissors"
        if @p2_move == "paper"
          return "player1"
        elsif @p2_move == "rock"
          return "player2"
        end
      end
    end

  end
end