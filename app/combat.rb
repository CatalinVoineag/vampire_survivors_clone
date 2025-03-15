class Combat
  attr_reader :args

  def initialize(args)
    @args = args
  end

  def self.call(args)
    new(args).call
  end

  def call
    args.state.enemies.each do |enemy|
      if args.state.game_state == 'attacking' && args.geometry.intersect_rect?(args.state.player.data, enemy.data)
        enemy.dead = true
      end

      if Kernel.tick_count % 60 == 0 &&
        args.geometry.intersect_rect?(args.state.player.data, enemy.data)

        args.state.player.life -= 10
        if args.state.player.life < 0
          args.state.player.dead = true
        end
      end
    end
  end
end
