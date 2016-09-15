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
    action = nil
    until action && pos && valid_action?(action) && valid_pos?(pos)
      input = get_input
      action = parse_action(input)
      pos = parse_pos(input)
    end

    case action
    when 'r'
      @board.reveal(pos)
    when 'f'
      @board.flag(pos)
    when 'u'
      @board.unflag(pos)
    end
  end

  def get_input
    puts "choose a position to reveal"
    gets.chomp
  end

  def parse_pos(string)
    string[1,3].split(",").map{|num| num.to_i-1}
  end

  def parse_action(string)
    string[0].downcase
  end

  def valid_pos?(pos)
    @board.valid_pos?(pos)
  end

  def valid_action?(action)
    ['r','f','u'].include?(action)
  end

  def game_over?
    @board.solved? || @board.bomb?
  end

end

if __FILE__ == $PROGRAM_NAME
  game = Game.new()
  game.play
end
