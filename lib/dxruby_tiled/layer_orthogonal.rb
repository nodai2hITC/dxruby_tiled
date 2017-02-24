module DXRuby
  module Tiled
    class OrthogonalLayer < Layer
      
      def draw(x, y, target = DXRuby::Window)
        tile_width, tile_height = @map.tile_width, @map.tile_height
        tile_images = @map.tilesets.tile_images
        left, top = xy_at(x - @offset_x, y - @offset_x)
        x_range = left..(left + (target.width  / tile_width  + 1).floor)
        y_range =  top..(top  + (target.height / tile_height + 1).floor)
        off_x = left * tile_width  + (x - @offset_x) % tile_width  - tile_width  / 2
        off_y =  top * tile_height + (y - @offset_y) % tile_height - tile_height / 2
        alpha = (@opacity * 255).floor
        x_range = x_range.to_a.reverse if @map.renderorder_x
        y_range = y_range.to_a.reverse if @map.renderorder_y
        
        y_range.each do |yy|
          x_range.each do |xx|
            image = tile_images[self[xx, yy]]
            target.draw_alpha(xx * tile_width  - off_x - image.width  / 2,
                              yy * tile_height - off_y - image.height / 2,
                              image, alpha)
          end
        end
      end
      
      def xy_at(x, y)
        return x / @map.tile_width, y / @map.tile_height
      end
      
      def at(x, y)
        return self[x / @map.tile_width, y / @map.tile_height]
      end
      
      def change_at(x, y, value)
        self[x / @map.tile_width, y / @map.tile_height] = value
      end
      
      def vertexs(x, y)
        w, h = @map.tile_width, @map.tile_height
        return [
          [ x * w    , y * h     ],
          [ x * w    , y * h + h ],
          [ x * w + w, y * h + h ],
          [ x * w + w, y * h     ]
        ]
      end
      
      def self.pixel_width(map)
        return map.tile_width * map.width
      end
      
      def self.pixel_height(map)
        return map.tile_height * map.height
      end
      
    end
  end
end
