class Tile
  attr_accessor :has_bomb, :has_flag, :adjacent_bombs, :revealed

  def initialize(has_bomb = false, has_flag = false)
    @has_bomb = has_bomb
    @has_flag = has_flag
    @revealed = false
    @adjacent_bombs = 0
  end

  def reveal
    @revealed = true
  end

  def increment_bomb_count
    @adjacent_bombs += 1
  end

  def revealed?
    @revealed
  end

  def has_bomb?
    @has_bomb
  end

  def has_flag?
    @has_flag
  end

  def set_bomb
    @has_bomb = true
  end

  def flag
    @has_flag = true
  end

  def unflag
    @has_flag = false
  end

  def to_s
    if @revealed
      return @adjacent_bombs if @adjacent_bombs > 0
      "_"
    else
      return "F" if @has_flag
      "*"
    end
  end
end
