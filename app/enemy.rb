class Enemy
  attr_reader :args
  attr_accessor :y, :x, :w, :h, :path, :dead, :direction, :attacking,
    :default_state_at, :sprite_animation_count, :sprite_hold

  def initialize(args, params: {})
    @args = args
    @y = params[:y]
    @x = params[:x]
    @w = params[:w]
    @h = params[:h]
    @speed = params[:speed]
    @path = params[:path]
    @dead = false
    @direction = 1
    @started_running_at = nil
    @attacking = false
    @default_state_at = nil
    @sprite_animation_count = 4
    @sprite_hold = 3
  end

  def move(tiles)
    handle_movement
    #improve_movement
    #new_movement(tiles)
  end

  def new_movement(tiles)
    enemy = args.state.enemies.first
    middle = {
      x: enemy.hitbox_data.x + (enemy.hitbox_data.w / 2),
      y: enemy.hitbox_data.y + (enemy.hitbox_data.h / 2),
      w: 1,
      h: 1,
      r: 255,
      g: 255,
      b: 255
    }

    tile = tiles.find { |x| x.intersect_rect?(middle) }
    player_tile = tiles.find {|x| x.intersect_rect?(args.state.player.middle)}

    neighbors = find_neighbors(tile, tiles)
    next_tile = neighbors.sort_by(&:distance_from_player).first

    next_tile.merge!(r: 99, g: 99, b: 10)
    tile.merge!(r: 255, g: 0, b: 0)

    args.state.enemy_tile = tile
    args.state.middle = middle
    args.state.next_tile = next_tile
    enemy_speed = 1.2

    unless next_tile == player_tile
      #if next_tile.x - args.state.map.x < real_x
      #  @x -= enemy_speed
      #  @direction = -1
      #  @started_running_at ||= Kernel.tick_count
      #elsif next_tile.x - args.state.map.x > real_x
      #  @x += enemy_speed
      #  @direction = 1
      #  @started_running_at ||= Kernel.tick_count
      #end

      args.outputs.debug << "NEXT TILE Y #{next_tile.y}"
      args.outputs.debug << "real_y #{real_y}"

      if next_tile.y - args.state.map.y < real_y
        @y -= enemy_speed
        @started_running_at ||= Kernel.tick_count
      elsif next_tile.y - args.state.map.y > real_y# && (next_tile.y - @y).abs > enemy_speed
        @y += enemy_speed
        @started_running_at ||= Kernel.tick_count
      end
    end
  end

  def data
    if attacking && !default_state_at.nil?
      attack_sprite
    else
      running_sprite
    end
  end

  def animation_frames
    @sprite_animation_count * @sprite_hold
  end

  def real_x
    x + args.state.map.x
  end

  def real_y
    y + args.state.map.y
  end

  private

  def handle_movement
    player = args.state.player
    enemy_speed = 1.2

    if player.real_x < @x
      @x -= enemy_speed
      @direction = -1
      @started_running_at ||= Kernel.tick_count
    elsif player.real_x > @x && (player.x - @x).abs > enemy_speed
      @x += enemy_speed
      @direction = 1
      @started_running_at ||= Kernel.tick_count
    end

    if player.real_y < @y
      @y -= enemy_speed
      @started_running_at ||= Kernel.tick_count
    elsif player.real_y > @y && (player.y - @y).abs > enemy_speed
      @y += enemy_speed
      @started_running_at ||= Kernel.tick_count
    end
  end

  def running_sprite
    if !@started_running_at
      {
        x: @x + args.state.map.x,
        y: @y + args.state.map.y,
        w: @w,
        h: @h,
        tile_x: 0,
        tile_y: 0,
        tile_w: @w,
        tile_h: @h,
        path: 'sprites/player/_Run.png',
        r: 255,
        g: 0,
        b: 0
      }
    else
      tile_index = @started_running_at.frame_index(
        count: 10,
        hold_for: 3,
        repeat: true
      )

      {
        x: @x + args.state.map.x,
        y: @y + args.state.map.y,
        w: @w,
        h: @h,
        path: 'sprites/player/_Run.png',
        tile_x: 0 + (tile_index * @w),
        tile_y: 0,
        tile_w: @w,
        tile_h: @h,
        flip_horizontally: @direction.negative?,
        r: 255,
        g: 0,
        b: 0
      }
    end
  end

  def attack_sprite
    tile_index = 0.frame_index(
      count: @sprite_animation_count,
      hold_for: @sprite_hold,
      repeat: true
    )

    {
      x: @x + args.state.map.x,
      y: @y + args.state.map.y,
      w: @w,
      h: @h,
      path: 'sprites/player/_Attack.png',
      tile_x: 0 + (tile_index * @w),
      tile_y: 0,
      tile_w: @w,
      tile_h: @h,
      flip_horizontally: @direction.negative?,
      r: 255,
      g: 0,
      b: 0
    }
  end

  def hitbox_data
    # make the width smaller and move the character in the middle of the new width
    {
      x: x + 20 + args.state.map.x,
      y: y + args.state.map.y,
      w: w - 40,
      h: h
    }
  end

  def improve_movement
    sorted_tiles = tiles.sort_by(&:distance_from_player).reverse

    args.outputs.debug << "Sorted_tiles #{sorted_tiles.first.distance_from_player}"
  end

  def find_neighbors(current_tile, tiles)
    neighbors = []

    left_tile = tiles.find { |tile| tile.x == current_tile.x - 40 && tile.y == current_tile.y }
    left_tile.merge!(r: 0, g: 0, b: 255)
    neighbors << left_tile

    right_tile = tiles.find { |tile| tile.x == current_tile.x + 40 && tile.y == current_tile.y }
    right_tile.merge!(r: 0, g: 0, b: 255)
    neighbors << right_tile

    up_tile = tiles.find { |tile| tile.x == current_tile.x && tile.y == current_tile.y + 40 }
    up_tile.merge!(r: 0, g: 0, b: 255)
    neighbors << up_tile

    down_tile = tiles.find { |tile| tile.x == current_tile.x && tile.y == current_tile.y - 40 }
    down_tile.merge!(r: 0, g: 0, b: 255)
    neighbors << down_tile

    args.outputs.debug << "LEFT TILE #{left_tile.distance_from_player}"
    args.outputs.debug << "RIGHT TILE #{right_tile.distance_from_player}"
    args.outputs.debug << "up TILE #{up_tile.distance_from_player}"
    args.outputs.debug << "down TILE #{down_tile.distance_from_player}"

    neighbors
  end
end
