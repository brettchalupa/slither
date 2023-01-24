# Slither

![Slither in bubble letters with an eye and tongue coming out of the S next to a red gem](https://user-images.githubusercontent.com/928367/212915843-3fb4cc63-d3d0-4fb8-bca7-f49481170c14.png)

A polished _Snake_ clone for web, desktop, and mobile by [Brett Chalupa](https://www.brettchalupa.com).

Built with [DragonRuby Game Toolkit](https://dragonruby.org/toolkit/game) Pro v4.1.

[![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png)](http://creativecommons.org/publicdomain/zero/1.0/)  
To the extent possible under law, [Brett Chalupa](https://brettchalupa.itch.io./slither) has waived all copyright and related or neighboring rights to Slither. This work is published from: United States.

## Developing

Replace `mygame` in the DRGTK engine:

```
rm -rf mygame
git clone git@github.com:brettchalupa/slither.git mygame
```

### iOS

- Drop in `metadata/ios_metadata.txt` with the proper config
- Add in the proper provisioning profiles in the engine root
- Start up the hot reload version: `$wizards.ios.start env: :hotload`

### Android

1. Install Android Studio
2. [Follow these steps](http://docs.dragonruby.org.s3-website-us-east-1.amazonaws.com/#--deploying-to-mobile-devices)

## Debug Shortcuts

- <kbd>7</kbd> — toggle invincibility
- <kbd>8</kbd> — pause gameplay movement
- <kbd>9</kbd> — eat gem
- <kbd>0</kbd> — display debug details (ex: framerate)
- <kbd>i</kbd> — reload sprites from disk
- <kbd>r</kbd> — reset the entire game state

Exit the debug-only Tilemap Tester scene with the secondary key.
