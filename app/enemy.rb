class Enemy
  attr_reader :args
  attr_accessor :y, :x, :w, :h, :path, :dead

  def initialize(args, params: {})
    @args = args
    @y = params[:y]
    @x = params[:x]
    @w = params[:w]
    @h = params[:h]
    @speed = params[:speed]
    @path = params[:path]
    @dead = false
    @direction = false
    @started_running_at = nil
  end

  def move
    handle_movement
  end

  def data
    running_sprite(args)
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

  def running_sprite(args)
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
end
