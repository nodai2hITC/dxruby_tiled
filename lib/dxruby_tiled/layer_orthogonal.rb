module DXRuby
  module Tiled
    class OrthogonalLayer < TileLayer
      def render(pos_x, pos_y, target = DXRuby::Window, z = 0, offset_x = 0, offset_y = 0, opacity = 1.0)
        super
        
        pos_x, pos_y = 0, 0 if @fixed
        off_x = offset_x + @offset_x - pos_x
        off_y = offset_y + @offset_y - pos_y
        x1, y1 = xy_at(@tile_width  - @tilesets.tile_right  - off_x,
                       @tile_height - @tilesets.tile_bottom - off_y)
        x2, y2 = xy_at(@render_target.width  - @tilesets.tile_left - off_x - 1,
                       @render_target.height - @tilesets.tile_top  - off_y - 1)
        
        (y1..(y2 + 1)).public_send(@renderorder_y ? :each : :reverse_each) do |y|
          (x1..(x2 + 1)).public_send(@renderorder_x ? :each : :reverse_each) do |x|
            @tilesets[self[x, y]].render(
              x * @tile_width  + off_x,
              y * @tile_height + off_y,
              @render_target)
          end
        end
        
        target.draw_alpha(0, 0, @render_target, @opacity * 255, z + @z_index)
      end
      alias_method :draw, :render
      
      def xy_at(pos_x, pos_y)
        return pos_x.to_i / @tile_width, pos_y.to_i / @tile_height
      end
      
      def at(pos_x, pos_y)
        self[pos_x.to_i / @tile_width, pos_y.to_i / @tile_height]
      end
      
      def change_at(pos_x, pos_y, value)
        self[pos_x.to_i / @tile_width, pos_y.to_i / @tile_height] = value
      end
      
      def vertexs(x, y)
        w, h = @tile_width, @tile_height
        return [
          [ x * w    , y * h     ],
          [ x * w    , y * h + h ],
          [ x * w + w, y * h + h ],
          [ x * w + w, y * h     ]
        ]
      end
      
      def self.pixel_width(map)
        map.tile_width * map.width
      end
      
      def self.pixel_height(map)
        map.tile_height * map.height
      end
    end
  end
end
