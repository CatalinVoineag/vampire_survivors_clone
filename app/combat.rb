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

      if enemy_intersect_player?(enemy) && !enemy.attacking
        enemy.attacking = true
        enemy.default_state_at = Kernel.tick_count + enemy.animation_frames
      end

      if enemy_intersect_player?(enemy) && enemy.attacking && finish_attack_animation?(enemy)
        args.state.player.life -= 10
        enemy.attacking = false
      end
    end
  end

  private

  def enemy_intersect_player?(enemy)
    tolerance = 32
    #puts "DATA #{args.state.player.data}"
    args.geometry.intersect_rect?(args.state.player.data, enemy.data, tolerance)
  end

  def finish_attack_animation?(enemy)
    enemy.default_state_at == Kernel.tick_count
  end
end
