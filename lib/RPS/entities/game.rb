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

    # def game_winner
      
    # end
  end

  class Round

    attr_reader :round_id, :game_id, :p1_move, :p2_move, :round_winner

    def initialize(data = {})
      @round_id = data['round_id']
      @game_id = data['game_id']
      @p1_move = data['p1_move']
      @p2_move = data['p2_move']
      @round_winner = data['round_winner']
      # return winner
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

    def winner
      if active?
        return nil
      elsif @p1_move == @p2_move
        return "tie"
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
