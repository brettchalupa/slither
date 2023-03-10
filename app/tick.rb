# Code that only gets run once on game start
def init(args)
  GameSetting.load_settings(args)
  HighScore.load(args)
  debug? ? args.gtk.show_cursor : args.gtk.hide_cursor
end

def tick(args)
  init(args) if args.state.tick_count == 0

  args.state.has_focus ||= true
  args.state.scene ||= :main_menu

  track_swipe(args) if args.gtk.platform?(:mobile) || debug?

  Scene.send("tick_#{args.state.scene}", args)

  debug_tick(args)
rescue FinishTick
end

# raise this as an easy way to end the current tick early
class FinishTick < StandardError; end

# code that only runs while developing
# put shortcuts and helpful info here
def debug_tick(args)
  return unless debug?

  debug_label(
    args, 24.from_right, 32.from_bottom,
    "v#{version} | DR v#{$gtk.version} (#{$gtk.platform}) | Ticks: #{args.state.tick_count} | FPS: #{args.gtk.current_framerate.round}",
    ALIGN_RIGHT)

  if args.inputs.keyboard.key_down.zero
    play_sfx(args, :select)
    args.state.render_debug_details = !args.state.render_debug_details
  end

  if args.inputs.keyboard.key_down.nine
    play_sfx(args, :select)
    Scene.eat_gem(args)
  end

  if args.inputs.keyboard.key_down.eight
    play_sfx(args, :select)
    args.state.gameplay.stop_movement = !args.state.gameplay.stop_movement
  end

  if args.inputs.keyboard.key_down.seven
    play_sfx(args, :select)
    args.state.gameplay.invincible = !args.state.gameplay.invincible
  end

  if args.inputs.keyboard.key_down.i
    play_sfx(args, :select)
    Sprite.reset_all(args)
    args.gtk.notify!("Sprites reloaded")
  end

  if args.inputs.keyboard.key_down.r
    play_sfx(args, :select)
    $gtk.reset
  end
end

# render a label that is only shown when in debug mode and the debug details
# are shown; toggle with +0+ key
def debug_label(args, x, y, text, align=ALIGN_LEFT)
  return unless debug?
  return unless args.state.render_debug_details

  args.outputs.debug << { x: x, y: y, text: text, alignment_enum: align }.merge(WHITE).label!
end

def draw_bg(args, color)
  args.outputs.background_color = color.values
end
