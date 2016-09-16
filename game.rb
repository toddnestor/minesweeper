require_relative "board"
require "yaml"
class Game
  attr_accessor :board
  def initialize(size = 9)
    @board = Board.new(size)
  end

  def play
    prompt_load_game if save_game_exist?
    take_turn until game_over?
    puts "Game over"
  end

  def prompt_load_game
    puts "Do you want to load a saved game? Type Y for yes"
    answer = gets.chomp
    if answer == "Y"
      list_saved_games
      puts "Enter number for game you want to load."
      num = gets.chomp
      load(get_filename(num.to_i)) if num.match(/^[0-9]{1,}$/)
    end
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
    when 's'
      save
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

  def save
    File.open(next_saved_game,"w") do |f|
      f.write @board.to_yaml
    end
  end

  def next_saved_game
    "game#{saved_games.length > 0 ? "-#{saved_games.length + 1}"}.minesweeper"
  end

  def load(filename)
    File.open(filename) do |f|
      @board = YAML::load(f.read.chomp)
    end
  end

  def saved_games
    Dir['saved_game/*']
  end

  def get_filename(num)
    saved_games[num-1]
  end

  def list_saved_games
    saved_games =

    saved_games.each_with_index do |game, i|
      puts "#{i+1}: #{game.split('.').first}"
    end
  end

  def save_game_exist?
    saved_games.length > 0?
  end


end

if __FILE__ == $PROGRAM_NAME
  game = Game.new()
  game.play
end
