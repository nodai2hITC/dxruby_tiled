module DXRuby
  module Tiled
    class IsometricLayer < TileLayer
      def render(pos_x, pos_y, target = DXRuby::Window, z = @z_index, offset_x = 0, offset_y = 0, opacity = 1.0)
        super
        
        pos_x, pos_y = 0, 0 if @fixed
        tile_width2, tile_height2 = @tile_width / 2, @tile_height / 2
        off_x = offset_x + @offset_x - pos_x
        off_y = offset_y + @offset_y - pos_y
        left, top = xy_at(@tile_width  - @tilesets.tile_right  - off_x,
                          @tile_height - @tilesets.tile_bottom - off_y)
        x_range = -1..((@render_target.width  - @tilesets.tile_left)    / @tile_width  + 2)
        y_range = -1..((@render_target.height - @tilesets.tile_top) * 2 / @tile_height + 4)
        
        y_range.public_send(@renderorder_y ? :each : :reverse_each) do |tmp_y|
          x_range.public_send(@renderorder_x ? :each : :reverse_each) do |tmp_x|
            x = left + tmp_x + tmp_y / 2
            y = top + (tmp_y + 1) / 2 - tmp_x
            @tilesets[self[x, y]].render(
              x * tile_width2  - y * tile_width2  + off_x,
              y * tile_height2 + x * tile_height2 + off_y,
              @render_target)
          end
        end
        
        target.draw_alpha(0, 0, @render_target, @opacity * 255, z + @z_index)
      end
      alias_method :draw, :render
      
      def xy_at(pos_x, pos_y)
        return (1.0 * pos_x / @tile_width  + 1.0 * pos_y / @tile_height).floor,
               (1.0 * pos_y / @tile_height - 1.0 * pos_x / @tile_width ).floor
      end
      
      def vertexs(x, y)
        w, h = @tile_width / 2, @tile_height / 2
        return [
          [ x * w - y * w    , y * h + x * h         ],
          [ x * w - y * w - w, y * h + x * h + h     ],
          [ x * w - y * w    , y * h + x * h + h * 2 ],
          [ x * w - y * w + w, y * h + x * h + h     ]
        ]
      end
      
      
      def self.pixel_width(map)
        map.tile_width  * (map.width + map.height) / 2
      end
      
      def self.pixel_height(map)
        map.tile_height * (map.width + map.height) / 2
      end
    end
  end
end
