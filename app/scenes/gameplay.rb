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

      args.state.game_over ||= false
      args.state.parts ||= []
      args.state.head ||= {
        x: TILE_SIZE * 5, y: TILE_SIZE * 4, new_direction: :up,
        w: TILE_SIZE, h: TILE_SIZE, r: 120, g: 220, b: 120
      }
      args.state.apple ||= spawn_apple(args)
      head = args.state.head
      args.outputs.labels << label(
        "SCORE: #{args.state.parts.length}",
        x: 20, y: 700, size: SIZE_LG, font: FONT_BOLD)

      unless args.state.game_over
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

          args.state.parts.each.with_index do |p, i|
            next_prev_pos = [p.x, p.y]
            p.x, p.y = prev_pos
            prev_pos = next_prev_pos
          end

          if args.state.parts.any? { |p| head.intersect_rect?(p) }
            args.state.game_over = true
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

        if head.intersect_rect?(args.state.apple)
          args.state.parts << head.clone.merge({ r: 60, b: 34 })
          args.state.apple = spawn_apple(args)
        end

      else
        args.outputs.labels << [
          label(
            "GAME OVER", x: args.grid.w / 2, y: 500,
            align: ALIGN_CENTER, size: SIZE_LG,
            font: FONT_BOLD_ITALIC,
          ),
          label(
            "Press SPACE to Restart",
            x: args.grid.w / 2, y: 360,
            align: ALIGN_CENTER, size: SIZE_MD,
            font: FONT_ITALIC,
          )
        ]
        if args.inputs.keyboard.key_down.space
          $gtk.reset
        end
      end

      draw_bg(args, BLUE)
      args.outputs.solids << [
        args.state.parts, args.state.apple, args.state.head
      ]
    end

    def spawn_apple(args)
      { x: rand(args.grid.w / TILE_SIZE) * TILE_SIZE,
        y: rand(args.grid.h / TILE_SIZE) * TILE_SIZE,
        w: TILE_SIZE, h: TILE_SIZE, r: 200, g: 40, b: 40 }
    end

  end
end
