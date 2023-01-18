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

      Menu.tick(args, :main_menu, options)

      labels = []
      labels << label(
        "v#{version}",
        x: 24.from_left, y: 24.from_top,
        size: SIZE_XS, align: ALIGN_LEFT)
      labels << label(
        "#{text(:made_by)} #{dev_title}",
        x: 24.from_left, y: 48.from_bottom,
        size: SIZE_XS, align: ALIGN_LEFT)
      labels << label(
        :controls_title,
        x: 24.from_right, y: 84.from_bottom,
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
        x: 24.from_right, y: 48.from_bottom,
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
