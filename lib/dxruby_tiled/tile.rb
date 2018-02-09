module DXRuby
  module Tiled
    class Tile
      attr_reader :image, :original_image, :offset_x, :offset_y, :adjusted_offset_y, :tileset,
                  :scale_x, :scale_y, :angle
      attr_accessor :type, :collision, :collision_enable
      
      def initialize(image, offset_x, offset_y, adjusted_offset_y, tileset = nil)
        @image = @original_image = image
        @offset_x = offset_x
        @offset_y = offset_y
        @adjusted_offset_y = adjusted_offset_y
        @tileset = tileset
        @type = nil
        @anim_time_total = 1
        @anim_time = [0]
        @anim_tile = [self]
        @collision = nil
        @collision_enable = true
        @scale_x = 1
        @scale_y = 1
        @angle   = 0
      end
      
      def width ; @image.width ; end
      def height; @image.height; end
      
      def render(x, y, target = DXRuby::Window, z_index = 0)
        target.draw(x + @offset_x, y + @adjusted_offset_y, @image, z_index)
      end
      alias_method :draw, :render
      
      def animate(current_time)
        time = current_time % @anim_time_total
        @anim_tile[@anim_time.rindex { |t| time >= t } ]
      end
      
      def animate!(current_time)
        time = current_time % @anim_time_total
        tile = @anim_tile[@anim_time.rindex { |t| time >= t } ]
        @image    = tile.original_image
        @offset_x = tile.offset_x
        @offset_y = tile.offset_y
        @adjusted_offset_y = tile.adjusted_offset_y
      end
      
      def set_animation(anim_time, anim_tile)
        @anim_time = anim_time
        @anim_tile = anim_tile
        @anim_time_total = @anim_time.pop
      end
      
      def to_sprite(x, y)
        TileObject.new(x: x, y: y, tile: self)
      end
    end
    
    class FlippedTile
      attr_reader :scale_x, :scale_y, :angle, :tile
      
      def initialize(tile, tileid, hex = false)
        @tile = tile
        if hex
          @scale_x, @scale_y, @angle = case tileid & 0xf0000000
          when 0x10000000 then [ 1,  1, 120]
          when 0x20000000 then [ 1,  1,  60]
          when 0x30000000 then [-1, -1,   0]
          when 0x40000000 then [ 1, -1,   0]
          when 0x50000000 then [-1,  1, 300]
          when 0x60000000 then [-1,  1, 240]
          when 0x70000000 then [-1,  1,   0]
          when 0x80000000 then [-1,  1,   0]
          when 0x90000000 then [-1,  1, 120]
          when 0xa0000000 then [-1,  1,  60]
          when 0xb0000000 then [ 1, -1,   0]
          when 0xc0000000 then [-1, -1,   0]
          when 0xd0000000 then [ 1,  1, 300]
          when 0xe0000000 then [ 1,  1, 240]
          when 0xf0000000 then [ 1,  1,   0]
          end
        else
          @scale_x, @scale_y, @angle = case tileid & 0xe0000000
          when 0x20000000 then [ 1, -1, 90]
          when 0x40000000 then [ 1, -1,  0]
          when 0x60000000 then [-1, -1, 90]
          when 0x80000000 then [-1,  1,  0]
          when 0xa0000000 then [ 1,  1, 90]
          when 0xc0000000 then [-1, -1,  0]
          when 0xe0000000 then [-1,  1, 90]
          end
        end
        extend DXRuby::Tiled::DiagonallyFlippedTile if @angle == 90
      end
      
      def render(x, y, target=DXRuby::Window, z_index = 0)
        target.draw_ex(x + offset_x, y + adjusted_offset_y, @tile.image,
                       { scale_x: @scale_x, scale_y: @scale_y, angle: @angle, z: z_index })
      end
      alias_method :draw, :render
      
      def width; @tile.width; end
      def height; @tile.height; end
      def image; @tile.image; end
      def original_image; @tile.original_image; end
      def offset_x; @tile.offset_x; end
      def offset_y; @tile.offset_y; end
      def adjusted_offset_y; @tile.adjusted_offset_y; end
      def tileset; @tile.tileset; end
      def type; @tile.type; end
      def type=(value); @tile.type = value; end
      def collision; @tile.collision; end
      def collision=(value); @tile.collision = value; end
      def collision_enable; @tile.collision_enable; end
      def collision_enable=(value); @tile.collision_enable = value; end
      
      def to_sprite(x, y)
        TileObject.new(x, y, self, rotation: @angle)
      end
    end
    
    module DiagonallyFlippedTile
      def width ; @tile.height; end
      def height; @tile.width ; end
      
      def offset_x
        @tile.offset_x + (@tile.height - @tile.width) / 2
      end
      
      def offset_y
        @tile.offset_y + (@tile.height - @tile.width) / 2
      end
      
      def adjusted_offset_y
        @tile.adjusted_offset_y + (@tile.height - @tile.width) / 2
      end
    end
  end
end

