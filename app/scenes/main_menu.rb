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

      if args.gtk.platform?(:desktop)
        options << {
          key: :quit,
          on_select: -> (args) { args.gtk.request_quit }
        }
      end

      Menu.tick(args, :main_menu, options)

      labels = []
      labels << label(
        "#{text(:made_by)} #{dev_title}",
        x: args.grid.left + 24, y: 48,
        size: SIZE_XS, align: ALIGN_LEFT)
      labels << label(
        :controls_title,
        x: args.grid.right - 24, y: 84,
        size: SIZE_SM, align: ALIGN_RIGHT)
      labels << label(
        args.inputs.controller_one.connected ? :controls_gamepad : :controls_keyboard,
        x: args.grid.right - 24, y: 48,
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
