# play a sound effect. the file in sounds/ must match the key name. ex:
# play_sfx(args, :select)
def play_sfx(args, key)
  if args.state.setting.sfx
    args.outputs.sounds << "sounds/#{key}.wav"
  end
end

def play_music(args, key)
  args.audio[:music] = { input: "sounds/#{key}.ogg", looping: true, }
  set_music_vol(args)
end

def set_music_vol(args)
  vol = args.state.setting.music ? 0.8 : 0.0
  args.audio[:music]&.gain = vol
end

def pause_music(args)
  args.audio[:music].paused = true
end

def resume_music(args)
  args.audio[:music].paused = false
end
