class Player
  attr_reader :args
  attr_accessor :y, :x, :w, :h, :speed, :path, :dead, :life, :direction,
    :started_running_at, :death_animation_end_at

  def initialize(args, params: {})
    @args = args
    @y = params[:y]
    @x = params[:x]
    @w = params[:w]
    @h = params[:h]
    @speed = params[:speed]
    @path = params[:path]
    @dead = false
    @life = 10
    @direction = 1
    @started_running_at = nil
    @sprite_attack_animation_count = 4
    @sprite_attack_hold = 3
    @death_animation_end_at = nil
  end

  def move
    speed = args.state.player.speed

    handle_movement
  end

  def data
    if args.state.game_state == 'playing' && args.state.player.started_running_at && !attack_key?
      running_sprite
    elsif attack_key? || args.state.game_state == 'attacking'
      args.state.game_state = 'attacking'
      args.state.default_state_at ||= Kernel.tick_count + animation_frames

      attack_sprite
    elsif args.state.game_state == 'playing'
      standing_sprite
    elsif args.state.game_state == 'pause' && args.state.player.dead && !args.state.player_corpse
      death_animation_end_at = Kernel.tick_count + 50
      death_sprite
    elsif args.state.game_state == 'pause' && args.state.player.dead && args.state.player_corpse
      single_death_sprite
    end

    # clean this up!!!
  end

  def animation_frames
    @sprite_attack_animation_count * @sprite_attack_hold
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

  def death_sprite
    tile_index = 0.frame_index(
      count: 10,
      hold_for: 5,
      repeat: true
    )

    {
      x: @x,
      y: @y,
      w: @w,
      h: @h,
      path: 'sprites/player/_DeathNoMovement.png',
      tile_x: 0 + (tile_index * @w),
      tile_y: 0,
      tile_w: @w,
      tile_h: @h,
      flip_horizontally: @direction.negative?
    }
  end

  def single_death_sprite
    {
      x: @x,
      y: @y,
      w: @w,
      h: @h,
      path: 'sprites/player/_DeathNoMovementSingle.png'
    }
  end
end
