module DXRuby
  module Tiled
    class StaggeredLayer < Layer
      
      def draw(x, y, target = DXRuby::Window)
        tile_width2, tile_height2 = @map.tile_width / 2, @map.tile_height / 2
        tile_images = @map.tilesets.tile_images
        left, top = xy_at(x - @offset_x, y - @offset_x)
        left -= 1
        top  -= 1
        off_x = x - tile_width2  + @offset_x
        off_y = y - tile_height2 + @offset_y
        alpha = (@opacity * 255).floor
        
        if @map.stagger_axis_y
          x_range = left..(left + target.width  / tile_width2  / 2 + 1).floor
          y_range =  top..(top  + target.height / tile_height2     + 3).floor
          
          y_range.each do |y2|
            x0 = @map.stagger_index_odd ^ y2.even? ? tile_width2 : 0
            x_range.each do |x2|
              image = tile_images[self[x2, y2]]
              target.draw_alpha(x0 + x2 * tile_width2 * 2 - off_x - image.width  / 2,
                                     y2 * tile_height2    - off_y - image.height / 2,
                                image, alpha)
            end
          end
        else
          x_range = left..(left + target.width  / tile_width2      + 3).floor
          y_range =  top..(top  + target.height / tile_height2 / 2 + 1).floor
          
          y_range.each do |y2|
            x_range.each do |x2|
              y0 = @map.stagger_index_odd ^ x2.even? ? tile_height2 : 0
              image = tile_images[self[x2, y2]]
              target.draw_alpha(     x2 * tile_width2      - off_x - image.width  / 2,
                                y0 + y2 * tile_height2 * 2 - off_y - image.height / 2,
                                image, alpha)
            end
          end
        end
      end
      
      def xy_at(x, y)
        if @map.stagger_axis_y
          y2 = y * 2 / @map.tile_height
          x -= @map.tile_width / 2 if @map.stagger_index_odd ^ y2.even?
          x2 = x / @map.tile_width
          x0 = x % @map.tile_width
          y0 = y % (@map.tile_height / 2)
          if (y0 < @map.tile_height / 2 - x0 * @map.tile_height / @map.tile_width)
            y2 -= 1
            x2 += @map.stagger_index_odd ^ y2.even? ? -1 : 0
          elsif (y0 < x0 * @map.tile_height / @map.tile_width - @map.tile_height / 2)
            y2 -= 1
            x2 += @map.stagger_index_odd ^ y2.even? ? 0 : 1
          end
        else
          x2 = x * 2 / @map.tile_width
          y -= @map.tile_height / 2 if @map.stagger_index_odd ^ x2.even?
          y2 = y / @map.tile_height
          x0 = x % (@map.tile_width / 2)
          y0 = y % @map.tile_height
          if (y0 < @map.tile_height / 2 - x0 * @map.tile_height / @map.tile_width)
            x2 -= 1
            y2 += @map.stagger_index_odd ^ x2.even? ? -1 : 0
          elsif (y0 > x0 * @map.tile_height / @map.tile_width + @map.tile_height / 2)
            x2 -= 1
            y2 += @map.stagger_index_odd ^ x2.even? ? 0 : 1
          end
        end
        return x2, y2
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
        w, h = @map.tile_width / 2, @map.tile_height / 2
        if @map.stagger_axis_y
          x0 = @map.stagger_index_odd ^ y.even? ? w : 0
          return [
            [ x0 + x * w * 2 + w    , y * h         ],
            [ x0 + x * w * 2        , y * h + h     ],
            [ x0 + x * w * 2 + w    , y * h + h * 2 ],
            [ x0 + x * w * 2 + w * 2, y * h + h     ]
          ]
        else
          y0 = @map.stagger_index_odd ^ x.even? ? h : 0
          return [
            [ x * w + w    , y0 + y * h * 2         ],
            [ x * w        , y0 + y * h * 2 + h     ],
            [ x * w + w    , y0 + y * h * 2 + h * 2 ],
            [ x * w + w * 2, y0 + y * h * 2 + h     ]
          ]
        end
      end
      
      
      def self.pixel_width(map)
        return map.stagger_axis_y ?
                map.tile_width * map.width + map.tile_width / 2 :
                map.tile_width * (map.width + 1) / 2
      end
      
      def self.pixel_height(map)
        return map.stagger_axis_y ?
                map.tile_height * (map.height + 1) / 2 :
                map.tile_height * map.height + map.tile_height / 2
      end
      
    end
  end
end
