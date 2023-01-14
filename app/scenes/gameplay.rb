module Scene
  class << self
    TILE_SIZE = 80

    def tick_gameplay(args)
      # focus tracking
      if !args.state.has_focus && args.inputs.keyboard.has_focus
        args.state.has_focus = true
      elsif args.state.has_focus && !args.inputs.keyboard.has_focus
        args.state.has_focus = false
      end

      # auto-pause & input-based pause
      if !args.state.has_focus || pause_down?(args)
        play_sfx(args, :select)
        return Scene.switch(args, :paused, reset: true)
      end

      args.state.gameplay.game_over ||= false
      args.state.gameplay.parts ||= []
      args.state.gameplay.head ||= {
        x: TILE_SIZE * 5, y: TILE_SIZE * 4, new_direction: :up,
        w: TILE_SIZE, h: TILE_SIZE,
      }.merge!(GREEN)
      head = args.state.gameplay.head
      parts = args.state.gameplay.parts
      args.state.gameplay.apple ||= spawn_apple(args, head, parts)
      args.outputs.labels << label(
        "#{text(:length)}: #{args.state.gameplay.parts.length}",
        x: 20, y: 700, size: SIZE_LG, font: FONT_BOLD)

      unless args.state.gameplay.game_over
        if args.state.tick_count % 12 == 0
          prev_pos = [head.x, head.y]

          head.direction = head.new_direction
          case head.direction
          when :up
            head.y += TILE_SIZE
          when :down
            head.y -= TILE_SIZE
          when :left
            head.x -= TILE_SIZE
          when :right
            head.x += TILE_SIZE
          end

          args.state.gameplay.parts.each.with_index do |p, i|
            next_prev_pos = [p.x, p.y]
            p.x, p.y = prev_pos
            prev_pos = next_prev_pos
          end

          if args.state.gameplay.parts.any? { |p| head.intersect_rect?(p) }
            args.state.gameplay.game_over = true
          end
        end

        if head.left >= args.grid.right
          head.x = args.grid.left
        elsif head.right <= args.grid.left
          head.x = args.grid.right - head.w
        elsif head.bottom >= args.grid.top
          head.y = args.grid.bottom
        elsif head.top <= args.grid.bottom
          head.y = args.grid.top - head.h
        end

        if head.direction == :up || head.direction == :down
          head.new_direction = :right if args.inputs.right
          head.new_direction = :left if args.inputs.left
        else
          head.new_direction = :up if args.inputs.up
          head.new_direction = :down if args.inputs.down
        end

        if head.intersect_rect?(args.state.gameplay.apple)
          play_sfx(args, :menu)
          args.state.gameplay.parts << head.clone.merge(DARK_GREEN)
          args.state.gameplay.apple = spawn_apple(args, head, parts)
        end
      else
        game_over(args)
      end

      draw_bg(args, BLUE)
      args.outputs.solids << [
        args.state.gameplay.parts,
        args.state.gameplay.apple,
        args.state.gameplay.head
      ]
    end

    def game_over(args)
      args.outputs.labels << [
        label(
          :game_over, x: args.grid.w / 2, y: 500,
          align: ALIGN_CENTER, size: SIZE_LG,
          font: FONT_BOLD_ITALIC,
        ),
        label(
          :restart,
          x: args.grid.w / 2, y: 360,
          align: ALIGN_CENTER, size: SIZE_MD,
          font: FONT_ITALIC,
        )
      ]
      if primary_down?(args.inputs)
        play_sfx(args, :select)
        Scene.switch(args, :gameplay, reset: true)
      end
    end

    def spawn_apple(args, head, parts)
      apple = { x: rand(args.grid.w / TILE_SIZE) * TILE_SIZE,
                y: rand(args.grid.h / TILE_SIZE) * TILE_SIZE,
                w: TILE_SIZE, h: TILE_SIZE }.merge!(DARK_RED)

      if apple.intersect_rect?(head) || parts.any? { |p| p.intersect_rect?(apple) }
        apple = spawn_apple(args, head, parts)
      end

      apple
    end
  end
end
