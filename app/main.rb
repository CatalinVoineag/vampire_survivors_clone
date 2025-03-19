require 'app/player'
require 'app/enemy'
require 'app/combat'

FPS = 60
ENEMIES = 1

def tick(args)
  args.outputs.solids << {
    x: 0,
    y: 0,
    w: args.grid.w,
    h: args.grid.h,
    r: 92,
    g: 120,
    b: 230,
  }

  args.state.player ||= spawn_player(args)
  args.state.enemies ||= []
  args.state.game_state ||= 'playing'

  args.state.player.move
  spawn_enemies(args)

  Combat.call(args) unless args.state.player.dead

  #if args.state.game_state != 'pause'
    if args.state.player.life.negative?
      args.state.player.dead = true 
      args.state.game_state = 'pause'
    end

    if args.state.player.life.negative? &&
      args.state.player.death_animation_end_at == Kernel.tick_count + 50

      args.state.game_state.player_corpse = true
    end

    args.outputs.debug << "LIFE #{args.state.player.life}"
    args.outputs.debug << "Tick #{Kernel.tick_count}"

    args.state.enemies.reject!(&:dead)

    args.outputs.debug << "PLAYER DATA #{args.state.player.data}"
    args.outputs.sprites << [
      args.state.player.data,
      args.state.enemies.map(&:data)
    ]

    if args.state.default_state_at == Kernel.tick_count
      args.state.game_state = 'playing'
      args.state.default_state_at = nil
    end

    args.state.enemies.map(&:move)
  #end
end

def playing_tick(args)
end

def spawn_player(args)
  Player.new(
    args,
    params: {
      x: 100,
      y: 280,
      w: 120,
      h: 80,
      speed: 3,
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
      h: 100,
    }
  )
end
