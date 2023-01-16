module Scene
  class << self
    # Debug-only view for testing tilemap locations and whether or not they
    # line up
    def tick_tilemap_tester(args)
      draw_bg(args, BLUE)


      if secondary_down?(args.inputs)
        Scene.switch(args, :main_menu)
      end

      labels = [
        label(:tilemap_tester, x: args.grid.w / 2,
              y: args.grid.top - 80, align: ALIGN_CENTER,
              size: SIZE_LG, font: FONT_BOLD)
      ]
      sprites = []

      Tile::MAP.each.with_index do |kv, i|
        k = kv[0]
        v = kv[1]
        x = Tile::SIZE * i + 200
        labels << label(k.to_s, x: x + Tile::SIZE / 2, y: 200.from_top, size: SIZE_XS, align: ALIGN_CENTER)
        sprites << { x: x, y: 320.from_top, w: Tile::SIZE, h: Tile::SIZE }.merge(Tile.for(k))
      end

      # building a custom snake to test
      sprites << { x: 200, y: 240, w: Tile::SIZE, h: Tile::SIZE }.merge(Tile.for(:head))
      sprites << { x: 280, y: 240, w: Tile::SIZE, h: Tile::SIZE }.merge(Tile.for(:body))
      sprites << { x: 360, y: 240, w: Tile::SIZE, h: Tile::SIZE }.merge(Tile.for(:body))
      sprites << { x: 440, y: 240, w: Tile::SIZE, h: Tile::SIZE, angle: 90 }.merge(Tile.for(:corner))
      sprites << { x: 440, y: 160, w: Tile::SIZE, h: Tile::SIZE, angle: 90 }.merge(Tile.for(:body))
      sprites << { x: 440, y: 80, w: Tile::SIZE, h: Tile::SIZE, angle: 270 }.merge(Tile.for(:corner))
      sprites << { x: 520, y: 80, w: Tile::SIZE, h: Tile::SIZE, }.merge(Tile.for(:tail))

      args.outputs.sprites << sprites
      args.outputs.labels << labels
    end
  end
end
