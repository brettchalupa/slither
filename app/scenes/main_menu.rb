module Scene
  class << self
    # what's displayed when your game starts
    def tick_main_menu(args)
      draw_bg(args, DARK_PURPLE)
      options = [
        {
          key: :start,
          on_select: -> (args) { Scene.switch(args, :gameplay, reset: true) }
        },
        {
          key: :settings,
          on_select: -> (args) { Scene.switch(args, :settings, reset: true, return_to: :main_menu) }
        },
      ]

      if debug?
        options << {
          key: :tilemap_tester,
          on_select: -> (args) { Scene.switch(args, :tilemap_tester) }
        }
      end

      if args.gtk.platform?(:desktop)
        options << {
          key: :quit,
          on_select: -> (args) { args.gtk.request_quit }
        }
      end

      Menu.tick(args, :main_menu, options, menu_y: 320)

      labels = []
      labels << label(
        "v#{version}",
        x: 32.from_left, y: 32.from_top,
        size: SIZE_XS, align: ALIGN_LEFT)

      high_score = HighScore.get(args)
      if high_score > 0
        labels << label(
          "#{text(:high_score)}: #{high_score}",
          x: 32.from_right, y: 32.from_top,
          size: SIZE_SM, align: ALIGN_RIGHT, font: FONT_BOLD)
      end
      credit = label(
        "#{text(:made_by)} #{dev_title}",
        x: 32.from_left, y: 48.from_bottom,
        size: SIZE_XS, align: ALIGN_LEFT)

      if args.gtk.platform?(:mobile) || args.state.render_debug_details
        credit_rect = credit.slice(:x, :y)
        credit_rect.x -= 14
        credit_rect.y -= 30
        credit_rect.merge!({ w: 280, h: 40 }).merge!(WHITE)
        args.outputs.borders << credit_rect
        if args.inputs.mouse.up && args.inputs.mouse.inside_rect?(credit_rect)
          args.gtk.openurl("https://www.brettchalupa.com")
        end
      end

      labels << credit
      labels << label(
        :controls_title,
        x: 32.from_right, y: 84.from_bottom,
        size: SIZE_SM, align: ALIGN_RIGHT)

      controls_key = if args.inputs.controller_one.connected
                       :controls_gamepad
                     elsif args.gtk.platform?(:mobile)
                       :controls_touch
                     else
                       :controls_keyboard
                     end

      labels << label(
        controls_key,
        x: 32.from_right, y: 48.from_bottom,
        size: SIZE_XS, align: ALIGN_RIGHT)

      args.outputs.labels << labels

      sprites = []
      sprites << {
        x: args.grid.w / 2 - 300, y: args.grid.top - 300,
        path: Sprite.for(:logo),
        w: 600, h: 225,
      }
      sprites << {
        x: 50, y: 80,
        path: Sprite.for(:bud),
        w: 150, h: 104,
      }
      args.outputs.sprites << sprites
    end
  end
end
