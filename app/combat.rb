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
      if args.state.player.state == 'attacking' && args.geometry.intersect_rect?(args.state.player.hitbox_data, enemy.data)
        enemy.dead = true
      end

      if enemy_intersect_player?(enemy) && !enemy.attacking
        args.outputs.debug << 'ATTACK'
        enemy.attacking = true
        enemy.default_state_at = Kernel.tick_count + enemy.animation_frames
      end

      if enemy_intersect_player?(enemy) && enemy.attacking && finish_attack_animation?(enemy)
        args.state.player.life -= 10
      end

      if finish_attack_animation?(enemy)
        enemy.attacking = false
        enemy.default_state_at = nil
      end
    end
  end

  private

  def enemy_intersect_player?(enemy)
    #puts "DATA #{args.state.player.data}"
    args.geometry.intersect_rect?(args.state.player.hitbox_data, enemy.hitbox_data)
  end

  def finish_attack_animation?(enemy)
    enemy.default_state_at == Kernel.tick_count
  end
end
