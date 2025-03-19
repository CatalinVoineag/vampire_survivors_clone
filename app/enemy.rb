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
    @sprite_animation_count = 6
    @sprite_hold = 4
  end

  def move
    handle_movement
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

  private

  def handle_movement
    player = args.state.player
    enemy_speed = 1.5

    if player.x < @x
      @x -= enemy_speed
      @direction = -1
      @started_running_at ||= Kernel.tick_count
    elsif player.x > @x && (player.x - @x).abs > enemy_speed
      @x += enemy_speed
      @direction = 1
      @started_running_at ||= Kernel.tick_count
    end

    if player.y < @y
      @y -= enemy_speed
      @started_running_at ||= Kernel.tick_count
    elsif player.y > @y && (player.y - @y).abs > enemy_speed
      @y += enemy_speed
      @started_running_at ||= Kernel.tick_count
    end
  end

  def running_sprite
    if !@started_running_at
      {
        x: @x,
        y: @y,
        w: @w,
        h: @h,
      }
    else
      tile_index = @started_running_at.frame_index(
        count: 8,
        hold_for: 4,
        repeat: true,
      )

      {
        x: @x,
        y: @y,
        w: @w,
        h: @h,
        path: 'sprites/enemy/Orc-Walk.png',
        tile_x: 0 + (tile_index * @w),
        tile_y: 0,
        tile_w: @w,
        tile_h: @h,
        flip_horizontally: @direction < 0,
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
      x: @x,
      y: @y,
      w: @w,
      h: @h,
      path: 'sprites/enemy/Orc-Attack01.png',
      tile_x: 0 + (tile_index * @w),
      tile_y: 0,
      tile_w: @w,
      tile_h: @h,
      flip_horizontally: @direction < 0
    }
  end
end
