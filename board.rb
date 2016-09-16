require_relative 'tile'
require "byebug"
class Board
  attr_accessor :grid, :bomb_positions, :bomb_selected
  alias_method :rows, :grid

  DELTAS = [
    [-1,1],
    [0,1],
    [1,1],
    [-1,0],
    [1,0],
    [-1,-1],
    [0,-1],
    [1,-1]
  ]

  BOMBS = 10

  def initialize(size=9)
    @bomb_positions = []
    @grid = Array.new(size) { Array.new(size) {Tile.new}}
    @bomb_selected = false
    populate_grid
  end

  def [](x,y)
    @grid[x][y]
  end

  def size
    @grid.length
  end

  def bomb?
    @bomb_selected
  end

  def reveal(pos)
    return if self[*pos].has_flag?

    if self[*pos].has_bomb?
      @bomb_selected = true
    else
      adjacent_positions(pos).each do |position|
        self[*position].reveal unless self[*position].has_flag?
      end
    end
  end

  def flag(pos)
    self[*pos].flag
  end

  def unflag(pos)
    self[*pos].unflag
  end

  def adjacent_positions(pos, final=[])
    return [pos] if self[*pos].adjacent_bombs > 0

    final << pos unless final.include?(pos)

    surrounding_tiles(pos).each do |pos2|
      final += adjacent_positions(pos2, final) unless final.include?(pos2)
    end

    final
  end

  def valid_pos?(pos)
    x,y = pos
    x >= 0 && y >= 0 && @grid[x] && @grid[x][y]
  end

  def solved?
    rows.all? do |row|
      row.all? do  |tile|
        tile.revealed? || tile.has_bomb?
      end
    end
  end


  def render
    puts "  #{(1..size).to_a.join(" ")}"
    rows.each_with_index do |row, i|
      puts "#{i+1} #{row.map(&:to_s).join(" ")}"
    end
  end

  private
  def populate_grid
    BOMBS.times do |num|
      pos = nil
      pos = get_random_pos until pos && !@bomb_positions.include?(pos)
      @bomb_positions << pos
      self[*pos].set_bomb
    end

    set_adjacent_bombs
  end

  def set_adjacent_bombs
    @bomb_positions.each {|pos| increment_bomb_counts(pos)}
  end

  def increment_bomb_counts(pos)
    surrounding_tiles(pos).each {|tile| self[*tile].increment_bomb_count}
  end

  def surrounding_tiles(pos)
    positions = []

    DELTAS.each do |delta|
      new_pos = [pos[0] + delta[0], pos[1] + delta[1]]
      positions << new_pos if valid_pos?(new_pos)
    end

    positions
  end

  def get_random_pos
    x = rand(0..8)
    y = rand(0..8)

    [x,y]
  end
end
