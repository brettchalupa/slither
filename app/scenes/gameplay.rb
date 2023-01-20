module Scene
  class << self
    def tick_gameplay(args)
      draw_bg(args, DARK_PURPLE)
      # focus tracking
      if !args.state.has_focus && args.inputs.keyboard.has_focus
        args.state.has_focus = true
      elsif args.state.has_focus && !args.inputs.keyboard.has_focus
        args.state.has_focus = false
      end

      # auto-pause & input-based pause
      if !args.state.has_focus || pause_down?(args)
        return pause(args)
      end

      args.state.gameplay.movement_tick_delay ||= 20
      args.state.gameplay.tick_counter ||= 0
      args.state.gameplay.game_over ||= false
      args.state.gameplay.bg_color ||= BLUE
      args.state.gameplay.parts ||= []
      args.state.gameplay.head ||= {
        x: Tile::SIZE * 5, y: Tile::SIZE * 4, new_direction: DIR_UP,
        w: Tile::SIZE, h: Tile::SIZE,
      }.merge(Tile.for(:head_only))
      head = args.state.gameplay.head
      parts = args.state.gameplay.parts
      args.state.gameplay.gem ||= spawn_gem(args)
      args.outputs.labels << label(
        "#{text(:length)}: #{args.state.gameplay.parts.length}" + "#{new_high_score?(args) ? '!' : nil }",
        x: Tile::SIZE.from_left, y: 20.from_top, size: SIZE_LG, font: FONT_BOLD)

      unless args.state.gameplay.game_over
        if args.state.gameplay.tick_counter >= args.state.gameplay.movement_tick_delay
          args.state.gameplay.tick_counter = 0

          prev_pos = [head.x, head.y]
          prev_angle = head.angle

          head.direction = head.new_direction
          case head.direction
          when DIR_UP
            head.y += Tile::SIZE
          when DIR_DOWN
            head.y -= Tile::SIZE
          when DIR_LEFT
            head.x -= Tile::SIZE
          when DIR_RIGHT
            head.x += Tile::SIZE
          end

          if head.direction == DIR_RIGHT
            head.flip_vertically = true
          else
            head.flip_vertically = false
          end
          head.angle = opposite_angle(angle_for_dir(head.direction))

          parts.each.with_index do |p, i|
            next_prev_pos = [p.x, p.y]
            next_prev_angle = p.angle
            p.x, p.y = prev_pos
            p.a = 255
            p.active = true
            p.angle = prev_angle
            p.corner = false # reset
            if p.angle == 180
              p.flip_vertically = true
            else
              p.flip_vertically = false
            end
            unless i + 1 == parts.length
              p.merge!(Tile.for(:body))
            end
            prev_pos = next_prev_pos
            prev_angle = next_prev_angle
          end

          check_for_corners(args, head, parts)

          position_tail(args, head, parts)
        else
          if !args.state.gameplay.stop_movement
            args.state.gameplay.tick_counter += 1
          end
        end

        if head.left >= args.grid.right - Tile::SIZE
          head.x = args.grid.left + Tile::SIZE
        elsif head.right <= args.grid.left + Tile::SIZE
          head.x = args.grid.right - head.w - Tile::SIZE
        elsif head.bottom >= args.grid.top - Tile::SIZE
          head.y = args.grid.bottom + Tile::SIZE
        elsif head.top <= args.grid.bottom + Tile::SIZE
          head.y = args.grid.top - head.h - Tile::SIZE
        end

        if head.direction == DIR_UP || head.direction == DIR_DOWN
          head.new_direction = DIR_RIGHT if right?(args)
          head.new_direction = DIR_LEFT if left?(args)
        else
          head.new_direction = DIR_UP if up?(args)
          head.new_direction = DIR_DOWN if down?(args)
        end

        args.state.gameplay.gem.angle = Math.sin(args.state.tick_count / 12) * 10

        active_parts = args.state.gameplay.parts.select { |p| p.active }

        if active_parts.length >= 1
          head.merge!(Tile.for(:head))
        else
          head.merge!(Tile.for(:head_only))
        end

        gem = args.state.gameplay.gem
        if args.geometry.distance(center_of(head), center_of(gem)) < Tile::SIZE * 1.5
          if active_parts.length >= 1
            head.merge!(Tile.for(:head_open))
          else
            head.merge!(Tile.for(:head_only_open))
          end
        end

        if active_parts.any? { |p| head.intersect_rect?(p) }
          end_the_game(args)
        end

        if head.intersect_rect?(gem)
          eat_gem(args)
        end
      else
        game_over(args)
      end

      sprites = [
        args.state.gameplay.parts,
        args.state.gameplay.gem,
        args.state.gameplay.head
      ]

      if args.gtk.platform?(:mobile) || args.state.render_debug_details
        pause_button = {
          x: 72.from_right,
          y: 72.from_top,
          w: 52,
          h: 52,
          path: Sprite.for(:pause),
        }
        if args.inputs.mouse.up && args.inputs.mouse.inside_rect?(pause_button)
          return pause(args)
        end
        sprites << pause_button
      end

      debug_label(args, 20.from_left, 32.from_bottom, "gameplay tick_counter: #{args.state.gameplay.tick_counter}")
      args.outputs.solids << { x: args.grid.left + Tile::SIZE, y: args.grid.bottom + Tile::SIZE, w: args.grid.w - Tile::SIZE * 2, h: args.grid.h - Tile::SIZE * 2 }.merge(args.state.gameplay.bg_color)
      args.outputs.sprites << sprites
    end

    def pause(args)
      play_sfx(args, :select)
      pause_music(args)
      Scene.switch(args, :paused, reset: true)
    end

    def end_the_game(args)
      args.state.gameplay.game_over = true

      if new_high_score?(args)
        args.state.gameplay.new_high_score = true
        HighScore.save(args, args.state.gameplay.parts.length)
      end

      raise FinishTick.new
    end

    def game_over(args)
      labels = [
        label(
          :game_over, x: args.grid.w / 2, y: 500,
          align: ALIGN_CENTER, size: SIZE_XL,
          font: FONT_BOLD_ITALIC,
        ),
      ]

      next_y = 380
      if args.state.gameplay.new_high_score
        labels << label(
          :new_high_score,
          x: args.grid.w / 2, y: next_y,
          align: ALIGN_CENTER, size: SIZE_MD,
          font: FONT_BOLD,
        )
        next_y = 260
      end

      labels << label(
        args.gtk.platform?(:mobile) ? :restart_mobile : :restart,
        x: args.grid.w / 2, y: next_y,
        align: ALIGN_CENTER, size: SIZE_MD,
        font: FONT_BOLD_ITALIC,
      )

      args.outputs.labels << labels
      if primary_down?(args.inputs) || args.inputs.mouse.click
        play_sfx(args, :select)
        Scene.switch(args, :gameplay, reset: true)
      end
    end

    def new_high_score?(args)
      HighScore.get(args) < args.state.gameplay.parts.length
    end

    def spawn_gem(args)
      gem = {
        x: rand((args.grid.w / Tile::SIZE) - 2) * Tile::SIZE + Tile::SIZE,
        y: rand((args.grid.h / Tile::SIZE) - 2) * Tile::SIZE + Tile::SIZE,
        w: Tile::SIZE, h: Tile::SIZE
      }.merge(Tile.for(:gem))

      if [].push(args.state.gameplay.head).concat(args.state.gameplay.parts).any? { |p| p.intersect_rect?(gem) }
        gem = spawn_gem(args)
      end

      gem
    end

    def eat_gem(args)
      play_sfx(args, :menu)
      args.state.gameplay.parts << args.state.gameplay.head.clone
        .merge({ a: 0 })
        .merge({ active: false })
        .merge(Tile.for(:tail))

      # increase speed every 5 parts
      if args.state.gameplay.movement_tick_delay > 1 && args.state.gameplay.parts.length % 5 == 0
        args.state.gameplay.movement_tick_delay -= 1
      end

      if args.state.gameplay.parts.length == 10
        args.state.gameplay.bg_color = ORANGE
      elsif args.state.gameplay.parts.length == 20
        args.state.gameplay.bg_color = PINK
      elsif args.state.gameplay.parts.length == 30
        args.state.gameplay.bg_color = YELLOW
      elsif args.state.gameplay.parts.length == 40
        args.state.gameplay.bg_color = RED
      elsif args.state.gameplay.parts.length == 50
        args.state.gameplay.bg_color = WHITE
      end

      args.state.gameplay.gem = spawn_gem(args)
    end

    # this is some gross conditional stuff but I don't know a better way to go
    # about it
    def check_for_corners(args, head, parts)
      # check for corners
      parts.each.with_index do |p, i|
        if i != parts.length - 1
          if i == 0
            pre = head
          else
            pre = parts[i - 1]
          end
          nex = parts[i + 1]
          if (pre.top != p.top && nex.top == p.top) ||
              (pre.top == p.top && nex.top != p.top)
            p.merge!(Tile.for(:corner))
            p.corner = true
            p.flip_vertically = false
            p.flip_horizontally = false


            # wrap stuff
            if nex.y - p.y > Tile::SIZE && pre.top == p.top && pre.left < p.left # UR wrap
              p.angle = 90
            elsif nex.y - p.y > Tile::SIZE && pre.top == p.top && pre.left > p.left # UL wrap
              p.angle = 180
            elsif p.y - nex.y > Tile::SIZE && pre.top == p.top && pre.left < p.left # LR wrap
              p.angle = 0
            elsif p.y - nex.y > Tile::SIZE && pre.top == p.top && pre.left > p.left # LL wrap
              p.angle = 270
            elsif p.x - nex.x > Tile::SIZE && pre.left == p.left && pre.top > p.top # LL wrap
              p.angle = 270
            elsif p.x - nex.x > Tile::SIZE && pre.left == p.left && pre.top < p.top # UL wrap
              p.angle = 180
            elsif nex.x - p.x > Tile::SIZE && pre.left == p.left && pre.top < p.top # UR wrap
              p.angle = 90
            elsif nex.x - p.x > Tile::SIZE && pre.left == p.left && pre.top > p.top # LR wrap
              p.angle = 0
            elsif pre.top == p.top && p.x - pre.x > Tile::SIZE && nex.left == p.left && nex.top > p.top # LL wrap
              p.angle = 270
            elsif pre.top == p.top && p.x - pre.x > Tile::SIZE && nex.left == p.left && nex.top < p.top # UL wrap
              p.angle = 180
            elsif pre.top == p.top && pre.x - p.x > Tile::SIZE && nex.left == p.left && nex.top < p.top # UR wrap
              p.angle = 90
            elsif pre.top == p.top && pre.x - p.x > Tile::SIZE && nex.left == p.left && nex.top > p.top # LR wrap
              p.angle = 0
            elsif pre.top == p.top && p.x - pre.x > Tile::SIZE && nex.left == p.left && nex.top < p.top # UL wrap
              p.angle = 180
            elsif pre.left == p.left && p.y - pre.y > Tile::SIZE && nex.top == p.top && nex.left < p.left # LR wrap
              p.angle = 0
            elsif pre.left == p.left && p.y - pre.y > Tile::SIZE && nex.top == p.top && nex.left > p.left # LL wrap
              p.angle = 270
            elsif pre.left == p.left && pre.y - p.y > Tile::SIZE && nex.top == p.top && nex.left < p.left # UR wrap
              p.angle = 90
            elsif pre.left == p.left && pre.y - p.y > Tile::SIZE && nex.top == p.top && nex.left > p.left # UL wrap
              p.angle = 180
              # normal corners
            elsif pre.top > p.top && p.left < nex.left # LL
              p.angle = 270
            elsif pre.top > p.top && p.left > nex.left # LR
              p.angle = 0
            elsif pre.top < p.top && p.left < nex.left # UL
              p.angle = 180
            elsif pre.top < p.top && p.left > nex.left # UR
              p.angle = 90
            elsif pre.left > p.left && p.top > nex.top # UL
              p.angle = 180
            elsif pre.left > p.left && p.top < nex.top # LL
              p.angle = 270
            elsif pre.left < p.left && p.top > nex.top # UR
              p.angle = 90
            elsif pre.left < p.left && p.top < nex.top # LR
              p.angle = 0
            else
              puts "missing case"
            end
          end
        end
      end
    end

    def position_tail(args, head, parts)
      if parts.length == 1
        parts.last.angle = head.angle
      elsif parts.length > 1
        before_tail = parts[-2]
        tail = parts[-1]
        if before_tail.corner
          if (before_tail.x - tail.x).abs <= Tile::SIZE && (before_tail.y - tail.y).abs <= Tile::SIZE
            if before_tail.top > tail.top
              tail.angle = 270
            elsif before_tail.top < tail.top
              tail.angle = 90
            elsif before_tail.left < tail.left
              tail.angle = 0
            elsif before_tail.left > tail.left
              tail.angle = 180
            end
          else # wrap stuff
            if before_tail.top > tail.top
              tail.angle = 90
            elsif before_tail.top < tail.top
              tail.angle = 270
            elsif before_tail.left < tail.left
              tail.angle = 180
            elsif before_tail.left > tail.left
              tail.angle = 0
            end
          end
        else
          parts[-1].angle = before_tail.angle
        end
      end
    end
  end
end
