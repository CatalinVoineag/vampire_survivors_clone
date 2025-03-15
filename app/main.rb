require 'app/player'
require 'app/enemy'
require 'app/combat'
FPS = 60

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
  args.state.enemies ||= [
    spawn_enemy(args),
    spawn_enemy(args),
    spawn_enemy(args)
  ]
  args.state.game_state ||= 'playing'

  args.state.player.move
  Combat.call(args)

  args.outputs.debug << "LIFE #{args.state.player.life}"
  args.outputs.debug << "Tick #{Kernel.tick_count}"

  args.state.enemies.reject! { |enemy| enemy.dead }

  args.outputs.sprites << [
    args.state.player.data,
    args.state.enemies.map(&:data)
  ]

  if args.state.default_state_at == Kernel.tick_count
    args.state.game_state = 'playing'
    args.state.default_state_at = nil
  end

  args.state.enemies.map(&:move)
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

