class Player
  attr_reader :args
  attr_accessor :y, :x, :w, :h, :speed, :path, :dead, :life, :direction, :started_running_at

  def initialize(args, params: {})
    @args = args
    @y = params[:y]
    @x = params[:x]
    @w = params[:w]
    @h = params[:h]
    @speed = params[:speed]
    @path = params[:path]
    @dead = false
    @life = 100
    @direction = 1
    @started_running_at = nil
  end

  def move
    speed = args.state.player.speed

    handle_movement
  end

  def data
    if args.state.game_state == 'playing' && args.state.player.started_running_at && !attack_key?
      running_sprite(args)
    elsif attack_key? || args.state.game_state == 'attacking'
      args.state.game_state = 'attacking'
      args.state.default_state_at ||= Kernel.tick_count + 7

      attack_sprite(args)
    elsif args.state.game_state == 'playing'
        standing_sprite(args)
    end
  end

  private

  def attack_key?
    args.inputs.keyboard.key_down.h || args.inputs.controller_one.key_down.a
  end

  def handle_movement
    if args.state.game_state == 'playing' 
      if args.inputs.left
        @x -= speed
        @direction = -1
        @started_running_at ||= Kernel.tick_count
      end

      if args.inputs.right
        @x += speed
        @direction = 1
        @started_running_at ||= Kernel.tick_count
      end

      if args.inputs.up
        travel_speed = args.inputs.right || args.inputs.left ? speed / 2 : speed
        @y += travel_speed
        @started_running_at ||= Kernel.tick_count
      end

      if args.inputs.down
        travel_speed = args.inputs.right || args.inputs.left ? speed / 2 : speed
        @y -= travel_speed
        @started_running_at ||= Kernel.tick_count
      end

      if !args.inputs.keyboard.directional_vector
        @started_running_at = nil
      end
    end
  end

  def running_sprite(args)
    if !@started_running_at
      tile_index = 0
    else
      how_many_frames_in_sprite_sheet = 10
      how_many_ticks_to_hold_each_frame = 3
      should_the_index_repeat = true
      tile_index = @started_running_at.frame_index(
        how_many_frames_in_sprite_sheet,
        how_many_ticks_to_hold_each_frame,
        should_the_index_repeat
      )
    end

    {
      x: @x,
      y: @y,
      w: @w,
      h: @h,
      path: 'sprites/player/_Run.png',
      tile_x: 0 + (tile_index * @w),
      tile_y: 0,
      tile_w: @w,
      tile_h: @h,
      flip_horizontally: @direction < 0
    }
  end

  def attack_sprite(args)
    how_many_frames_in_sprite_sheet = 4
    how_many_ticks_to_hold_each_frame = 3
    should_the_index_repeat = true
    tile_index = 0.frame_index(
      how_many_frames_in_sprite_sheet,
      how_many_ticks_to_hold_each_frame,
      should_the_index_repeat
    )

    {
      x: @x,
      y: @y,
      w: @w,
      h: @h,
      path: 'sprites/player/_Attack.png',
      tile_x: 0 + (tile_index * @w),
      tile_y: 0,
      tile_w: @w,
      tile_h: @h,
      flip_horizontally: @direction < 0
    }
  end

  def standing_sprite(args)
    how_many_frames_in_sprite_sheet = 10
    how_many_ticks_to_hold_each_frame = 7
    should_the_index_repeat = true
    tile_index = 0.frame_index(
      how_many_frames_in_sprite_sheet,
      how_many_ticks_to_hold_each_frame,
      should_the_index_repeat,
    )

    {
      x: @x,
      y: @y,
      w: @w,
      h: @h,
      path: 'sprites/player/_Idle.png',
      tile_x: 0 + (tile_index * @w),
      tile_y: 0,
      tile_w: @w,
      tile_h: @h,
      flip_horizontally: @direction < 0
    }
  end
end
