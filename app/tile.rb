module Tile
  SIZE = 80
  MAP = {
    body: {
      tile_x: 504,
      tile_y: 268,
    },
    corner: {
      tile_x: 1176,
      tile_y: 74,
    },
    head: {
      tile_x: 490,
      tile_y: 746,
    },
    head_only: {
      tile_x: 45,
      tile_y: 1036,
    },
    head_open: {
      tile_x: 490,
      tile_y: 64,
    },
    head_only_open: {
      tile_x: 28,
      tile_y: 68,
    },
    tail: {
      tile_x: 260,
      tile_y: 272,
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
