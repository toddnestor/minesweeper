require_relative "board"
require "yaml"

class Game
  attr_accessor :board, :loaded_game
  def initialize(size = 9)
    @board = Board.new(size)
  end

  def play
    prompt_load_game if save_game_exist?
    take_turn until game_over?

    if @board.solved?
      puts "You won!"
      if @loaded_game
        puts "Do you want to delete the saved game? Enter Y for yes"
        maybe_delete_game(gets.chomp)
      end
    else
      puts "You lost!"
    end

    puts "Game over. Press enter to exit."
    gets
  end

  def maybe_delete_game(action)
    return unless action == 'Y'

    File.delete(@loaded_game)
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
    until action && pos && valid_action?(action) && (doesnt_need_position(action) || valid_pos?(pos))
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
    when 'e'
      abort
    end
  end

  def doesnt_need_position(action)
    ['s','e'].include?(action)
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
    ['r','f','u','s','e'].include?(action)
  end

  def game_over?
    @board.solved? || @board.bomb?
  end

  def save
    filename = @loaded_game ? @loaded_game : next_saved_game
    File.open(filename,"w") do |f|
      f.write @board.to_yaml
    end
    puts "Game is saved!"
    sleep(1)
  end

  def next_saved_game
    "saved_game/game#{saved_games.length > 0 ? "-#{saved_games.length + 1}" : ""}.minesweeper"
  end

  def load(filename)
    File.open(filename) do |f|
      @board = YAML::load(f.read.chomp)
    end
    @loaded_game = filename
  end

  def saved_games
    Dir['saved_game/*'].sort
  end

  def get_filename(num)
    saved_games[num-1]
  end

  def list_saved_games
    saved_games.each_with_index do |game, i|
      puts "#{i+1}: #{game.split('/')[1].split('.').first}"
    end
  end

  def save_game_exist?
    saved_games.length > 0
  end
end

if __FILE__ == $PROGRAM_NAME
  game = Game.new()
  game.play
end
