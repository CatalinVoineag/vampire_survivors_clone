class Player
  attr_reader :args
  attr_accessor :y, :x, :w, :h, :speed, :path, :dead, :life, :direction,
    :started_running_at, :death_animation_end_at, :state

  def initialize(args, params: {})
    @args = args
    @y = params[:y]
    @x = params[:x]
    @w = params[:w]
    @h = params[:h]
    @speed = params[:speed] / 2
    @path = params[:path]
    @dead = false
    @life = 1000000
    @direction = 1
    @started_running_at = nil
    @sprite_attack_animation_count = 4
    @sprite_attack_hold = 3
    @death_animation_end_at = nil
    @state = 'idle'
  end

  def real_x
    x - args.state.map.x
  end

  def real_y
    y - args.state.map.y
  end

  def move
    speed = args.state.player.speed

    handle_movement
  end

  def data
    if @state == 'idle' && args.state.player.started_running_at && !attack_key?
      running_sprite
    elsif attack_key? || @state == 'attacking'
      @state = 'attacking'
      args.state.default_state_at ||= Kernel.tick_count + animation_frames

      attack_sprite
    elsif @state == 'idle'
      standing_sprite
    end
  end

  def animation_frames
    @sprite_attack_animation_count * @sprite_attack_hold
  end

  def hitbox_data
    # make the width smaller and move the character in the middle of the new width
    {
      x: x + 20,
      y: y,
      w: w - 40,
      h: h
    }
  end

  def middle
    {
      x: x + (w / 2),
      y: y + (h / 2),
      w: 1,
      h: 1,
      r: 39,
      g: 183,
      b: 227
    }
  end

  private

  def attack_key?
    args.inputs.keyboard.key_down.h || args.inputs.controller_one.key_down.a
  end

  def handle_movement
    if @state == 'idle'
      if args.inputs.left
        if hit_left_side?
          @started_running_at ||= Kernel.tick_count
          return
        end

        @x -= speed
        args.state.map.x += (speed * args.state.camera.scale)
        @direction = -1
        @started_running_at ||= Kernel.tick_count
      end

      if args.inputs.right
        if hit_right_side?
          @started_running_at ||= Kernel.tick_count
          return
        end

        @x += speed
        args.state.map.x -= (speed * args.state.camera.scale)
        @direction = 1
        @started_running_at ||= Kernel.tick_count
      end

      if args.inputs.up
        if hit_up?
          @started_running_at ||= Kernel.tick_count
          return
        end

        travel_speed = args.inputs.right || args.inputs.left ? speed / 2 : speed
        @y += travel_speed
        args.state.map.y -= (speed * args.state.camera.scale)
        @started_running_at ||= Kernel.tick_count
      end

      if args.inputs.down
        if hit_down?
          @started_running_at ||= Kernel.tick_count
          return
        end

        travel_speed = args.inputs.right || args.inputs.left ? speed / 2 : speed
        @y -= travel_speed
        args.state.map.y += (speed * args.state.camera.scale)
        @started_running_at ||= Kernel.tick_count
      end

      @started_running_at = nil unless args.inputs.keyboard.directional_vector
    end
  end

  def running_sprite
    if !@started_running_at
      tile_index = 0
    else
      tile_index = @started_running_at.frame_index(
        count: 10,
        hold_for: 3,
        repeat: true
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
      flip_horizontally: @direction.negative?
    }
  end

  def attack_sprite
    tile_index = 0.frame_index(
      count: @sprite_attack_animation_count,
      hold_for: @sprite_attack_hold,
      repeat: true
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
      flip_horizontally: @direction.negative?
    }
  end

  def standing_sprite
    tile_index = 0.frame_index(
      count: 10,
      hold_for: 7,
      repeat: true
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
      flip_horizontally: @direction.negative?
    }
  end

  def hit_right_side?
    # the magic window camera moves the map as well as the player, like a moving staircase 
    @x + (@w/2) + args.state.map.x.abs > args.state.map.w
  end

  def hit_left_side?
    @x + (@w/2) - args.state.map.x.abs < 0
  end

  def hit_up?
    @y + (@h/2) + args.state.map.y.abs > args.state.map.h
  end

  def hit_down?
    @y - args.state.map.y.abs < 0
  end
end
