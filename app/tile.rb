module Tile
  MAP = {
    body: {
      tile_x: 740,
      tile_y: 754,
    },
    corner: {
      tile_x: 729,
      tile_y: 50,
    },
    head: {
      tile_x: 486,
      tile_y: 754,
    },
    tail: {
      tile_x: 260,
      tile_y: 280,
    },
    gem: {
      tile_x: 260,
      tile_y: 511,
    },
  }

  def self.for(key)
    MAP.fetch(key).merge({
      tile_w: 147,
      tile_h: 147,
      path: Sprite.for(:spritesheet)
    })
  end
end
