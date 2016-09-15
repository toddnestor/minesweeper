require_relative "board"

class Game
  attr_accessor :board
  def initialize(size = 9)
    @board = Board.new(size)
  end

  def play
    take_turn until game_over?
    puts "Game over"
  end

  def take_turn
    @board.render

    pos = nil
    pos = get_pos until pos && valid_pos?(pos)

    @board.reveal(pos)
  end

  def get_pos
    puts "choose a position to reveal"
    gets.chomp.split(",").map{|num| num.to_i-1}
  end

  def valid_pos?(pos)
    @board.valid_pos?(pos)
  end

  def game_over?
    @board.solved? || @board.bomb?
  end

end

if __FILE__ == $PROGRAM_NAME
  game = Game.new()
  game.play
end
