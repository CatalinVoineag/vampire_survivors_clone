require 'app/player'
require 'app/enemy'
require 'app/combat'

FPS = 60
ENEMIES = 1
STARTING_PLAYER_X = (1280 / 2) - (120 / 2)
STARTING_PLAYER_Y = (720 / 2) - (80 / 2)

def tick(args)
  args.state.game_state ||= 'playing'

  args.state.map.x ||= 0
  args.state.map.y ||= 0
  args.state.map.w ||= args.grid.w
  args.state.map.h ||= args.grid.h
  args.state.camera.scale ||= 1.00

  send("#{args.state.game_state}_tick", args)
end

def draw_map(args)
  {
    x: args.state.map.x,
    y: args.state.map.y,
    w: args.state.map.w,
    h: args.state.map.h,
    r: 3,
    g: 69,
    b: 0
  }
end

def tiles(args)
  tile_size = 40
  x_tiles = (args.grid.w / tile_size).to_i
  y_tiles = (args.grid.h / tile_size).to_i
  results = []

  x_tiles.times do |x_item|
    y_tiles.times do |y_item|
      x_value = (x_item * tile_size) + args.state.map.x
      y_value = (y_item * tile_size) + args.state.map.y

      results << {
        x: x_value,
        y: y_value,
        w: tile_size,
        h: tile_size,
        path: 'sprites/Pasto[1].png',
        tile_x: 0,
        tile_y: 0,
        tile_w: tile_size,
        tile_h: tile_size
      }
    end
  end

  results
end

def playing_tick(args)
  args.state.player ||= spawn_player(args)
  args.state.enemies ||= []

  args.outputs.solids << {
    x: 0,
    y: 0,
    w: 1920,
    h: 1080,
    r: 0,
    g: 0,
    b: 0
  }

  args.outputs.solids << draw_map(args)
  args.outputs.debug << "PLAYR #{args.state.player.data}"
  args.outputs.debug << "MAP #{args.state.map}"
  args.outputs.debug << "GRID #{args.grid.w}"

  args.outputs.debug << ("CORNER #{(1920 - args.state.map.w) /2}")

  args.state.player.move
  spawn_enemies(args)

  Combat.call(args) unless args.state.player.dead

  if args.state.player.life.negative?
    args.state.player.dead = true
    args.state.game_state = 'pause'
  end

  if args.state.player.life.negative? &&
    args.state.player.death_animation_end_at == Kernel.tick_count + 50

    args.state.game_state.player_corpse = true
  end

  args.state.enemies.reject!(&:dead)

  args.outputs.debug << "PLAYER DATA #{args.state.player.data}"
  args.outputs.debug << "ENEMY DATA #{args.state.enemies.first.data}"
  args.outputs.sprites << [
    tiles(args),
    args.state.player.data,
    args.state.enemies.map(&:data)
  ]

  if args.state.default_state_at == Kernel.tick_count
    args.state.player.state = 'idle'
    args.state.default_state_at = nil
  end

  args.state.enemies.map(&:move)
end

def pause_tick(args)
  labels = {
    x: 260,
    y: args.grid.h - 90,
    text: 'GAME OVER',
    size_enum: 3
  }

  args.outputs.labels << labels

  if args.inputs.keyboard.key_down.h || args.inputs.controller_one.key_down.a
    $gtk.reset
  end
end

def spawn_player(args)
  Player.new(
    args,
    params: {
      x: STARTING_PLAYER_X,
      y: STARTING_PLAYER_Y,
      w: 120,
      h: 80,
      speed: 3
    }
  )
end

def spawn_enemies(args)
  return unless args.state.enemies.count < ENEMIES

  enemies_to_spawn = ENEMIES - args.state.enemies.count
  enemies_to_spawn.times do
    args.state.enemies << spawn_enemy(args)
  end
end

def spawn_enemy(args)
  Enemy.new(
    args,
    params: {
      x: rand(args.grid.w * 0.9),
      y: rand(args.grid.h * 0.9),
      w: 100,
      h: 100
    }
  )
end
