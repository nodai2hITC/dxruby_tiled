module DXRuby
  module Tiled
    class Tilesets
      attr_reader :tiles, :tile_left, :tile_right, :tile_top, :tile_bottom
      
      def initialize(data, map)
        @last_time = 0
        @tiles = {}
        dummy_tile = Tile.new(DXRuby::Image.new(map.tile_width, map.tile_height), 0, 0, 0)
        def dummy_tile.render(x, y, target = DXRuby::Window, z_index = 0); end
        def dummy_tile.draw(x, y, target = DXRuby::Window, z_index = 0); end
        @tiles[0] = dummy_tile
        @tiles.default = dummy_tile
        
        @animations = []
        @tilesets = data.map { |tileset| Tileset.new(tileset, map) }
        hex = map.orientation == HexagonalLayer
        @tilesets.each do |tileset|
          gid = tileset.firstgid
          tileset.tiles.each_with_index do |tile, i|
            next unless tile
            @tiles[gid + i] = tile
            range = hex ? 1..15 : 1..7
            k     = hex ? 0x10000000 : 0x20000000
            range.each do |j|
              tileid = j * k + gid + i
              @tiles[tileid] = FlippedTile.new(tile, tileid, hex)
            end
          end
          tileset.animations.each { |i| @animations.push(gid + i) }
        end
        @tile_left   = @tiles.values.map { |tile| tile.offset_x }.min
        @tile_top    = @tiles.values.map { |tile| tile.offset_y }.min
        @tile_right  = @tiles.values.map { |tile| tile.offset_x + tile.width  }.max
        @tile_bottom = @tiles.values.map { |tile| tile.offset_y + tile.height }.max
      end
      
      def [](num)
        @tiles[num]
      end
      
      def animate()
        return if @last_time == DXRuby::Window::running_time
        @last_time = DXRuby::Window::running_time
        
        @animations.each { |i| @tiles[i].animate!(@last_time) }
      end
      
      def gid_adjusted_by_source(gid, source)
        gid + @tilesets.find { |tileset| tileset.source == source }.firstgid - 1
      end
      
      def dispose()
        @tilesets.each_value { |tileset| tileset.dispose() }
        @tiles[0].image.dispose()
      end
      
      def delayed_dispose()
        @tilesets.each_value { |tileset| tileset.delayed_dispose() }
        @tiles[0].image.delayed_dispose()
      end
      
      def disposed?()
        @tiles[0].image.disposed?()
      end
    end
  end
end
