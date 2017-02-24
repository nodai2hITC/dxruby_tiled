require "pry"

module DXRuby
  module Tiled
    class IsometricLayer < Layer
      
      def draw(x, y, target = DXRuby::Window)
        tile_width2, tile_height2 = @map.tile_width / 2, @map.tile_height / 2
        tile_images = @map.tilesets.tile_images
        left, top = xy_at(x - @offset_x, y - @offset_x)
        left -= 1
        top  -= 1
        x_range = 0..(target.width  / tile_width2 / 2 + 1).floor
        y_range = 0..(target.height / tile_height2    + 3).floor
        off_x = x - @map.pixel_width / 2 + @offset_x
        off_y = y - tile_height2 + @offset_y
        alpha = (@opacity * 255).to_i
        
        y_range.each do |yy|
          x_range.each do |xx|
            x2 = left + xx + yy / 2
            y2 = top  - xx + (yy + 1) / 2
            image = tile_images[self[x2, y2]]
            target.draw_alpha(x2 * tile_width2  - y2 * tile_width2  - off_x - image.width  / 2,
                              y2 * tile_height2 + x2 * tile_height2 - off_y - image.height / 2,
                              image, alpha)
          end
        end
      end
      
      def xy_at(tmp_x, y)
        x = tmp_x - @map.pixel_width / 2
        return (1.0 * x / @map.tile_width + 1.0 * y / @map.tile_height).floor,
                (1.0 * y / @map.tile_height - 1.0 * x / @map.tile_width).floor
      end
      
      def at(x, y)
        tmp_x, tmp_y = xy_at(x, y)
        return self[tmp_x, tmp_y]
      end
      
      def change_at(x, y, value)
        tmp_x, tmp_y = xy_at(x, y)
        self[tmp_x, tmp_y] = value
      end
      
      def vertexs(x, y)
        x0 = @map.pixel_width / 2
        w, h = @map.tile_width / 2, @map.tile_height / 2
        return [
          [ x0 + x * w - y * w    , y * h + x * h         ],
          [ x0 + x * w - y * w - w, y * h + x * h + h     ],
          [ x0 + x * w - y * w    , y * h + x * h + h * 2 ],
          [ x0 + x * w - y * w + w, y * h + x * h + h     ]
        ]
      end
      
      
      def self.pixel_width(map)
        return map.tile_width  * (map.width + map.height) / 2
      end
      
      def self.pixel_height(map)
        return map.tile_height * (map.width + map.height) / 2
      end
      
    end
  end
end
