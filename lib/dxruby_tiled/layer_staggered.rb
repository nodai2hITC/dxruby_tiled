module DXRuby
  module Tiled
    class StaggeredLayer < TileLayer
      def initialize(data, map)
        super
        @stagger_axis_y    = map.stagger_axis_y
        @stagger_index_odd = map.stagger_index_odd
      end
      
      def render(pos_x, pos_y, target = DXRuby::Window, z = @z_index, offset_x = 0, offset_y = 0, opacity = 1.0)
        super
        
        pos_x, pos_y = 0, 0 if @fixed
        tile_width2  = @tile_width / 2
        tile_height2 = @tile_height / 2
        off_x = offset_x + @offset_x - pos_x
        off_y = offset_y + @offset_y - pos_y
        x1, y1 = xy_at(@tile_width  - @tilesets.tile_right  - off_x,
                       @tile_height - @tilesets.tile_bottom - off_y)
        x2, y2 = xy_at(@render_target.width  - @tilesets.tile_left - off_x - 1,
                       @render_target.height - @tilesets.tile_top  - off_y - 1)
        x_range = ((x1 - 1)..(x2 + 1))
        y_range = ((y1 - 1)..(y2 + 1))
        
        if @stagger_axis_y
          y_range.public_send(@renderorder_y ? :each : :reverse_each) do |y|
            x0 = @stagger_index_odd ^ y.even? ? tile_width2 : 0
            x_range.public_send(@renderorder_x ? :each : :reverse_each) do |x|
              @tilesets[self[x, y]].render(
                x * @tile_width   + off_x + x0,
                y *  tile_height2 + off_y,
                @render_target)
            end
          end
        else
          y_range.public_send(@renderorder_y ? :each : :reverse_each) do |y|
            x_range.public_send(@renderorder_x ? :each : :reverse_each) do |x|
              next if @stagger_index_odd ^ x.even?
              @tilesets[self[x, y]].render(
                x *  tile_width2 + off_x,
                y * @tile_height + off_y,
                @render_target)
            end
            x_range.public_send(@renderorder_x ? :each : :reverse_each) do |x|
              next unless @stagger_index_odd ^ x.even?
              @tilesets[self[x, y]].render(
                x *  tile_width2 + off_x,
                y * @tile_height + off_y + tile_height2,
                @render_target)
            end
          end
        end
        
        target.draw_alpha(0, 0, @render_target, @opacity * 255, z + @z_index)
      end
      alias_method :draw, :render
      
      def xy_at(pos_x, pos_y)
        if @stagger_axis_y
          y = (pos_y * 2 / @tile_height).floor
          pos_x -= @tile_width / 2 if @stagger_index_odd ^ y.even?
          x = (pos_x / @tile_width).floor
          dx = pos_x % @tile_width
          dy = pos_y % (@tile_height / 2)
          if (dy < @tile_height / 2 - dx * @tile_height / @tile_width)
            y -= 1
            x += @stagger_index_odd ^ y.even? ? -1 : 0
          elsif (dy < dx * @tile_height / @tile_width - @tile_height / 2)
            y -= 1
            x += @stagger_index_odd ^ y.even? ? 0 : 1
          end
        else
          x = (pos_x * 2 / @tile_width).floor
          pos_y -= @tile_height / 2 if @stagger_index_odd ^ x.even?
          y = (pos_y / @tile_height).floor
          dx = pos_x % (@tile_width / 2)
          dy = pos_y % @tile_height
          if (dy < @tile_height / 2 - dx * @tile_height / @tile_width)
            x -= 1
            y += @stagger_index_odd ^ x.even? ? -1 : 0
          elsif (dy > dx * @tile_height / @tile_width + @tile_height / 2)
            x -= 1
            y += @stagger_index_odd ^ x.even? ? 0 : 1
          end
        end
        return x, y
      end
      
      def vertexs(x, y)
        w, h = @tile_width / 2, @tile_height / 2
        if @stagger_axis_y
          x0 = @stagger_index_odd ^ y.even? ? w : 0
          return [
            [ x0 + x * w * 2 + w    , y * h         ],
            [ x0 + x * w * 2        , y * h + h     ],
            [ x0 + x * w * 2 + w    , y * h + h * 2 ],
            [ x0 + x * w * 2 + w * 2, y * h + h     ]
          ]
        else
          y0 = @stagger_index_odd ^ x.even? ? h : 0
          return [
            [ x * w + w    , y0 + y * h * 2         ],
            [ x * w        , y0 + y * h * 2 + h     ],
            [ x * w + w    , y0 + y * h * 2 + h * 2 ],
            [ x * w + w * 2, y0 + y * h * 2 + h     ]
          ]
        end
      end
      
      
      def self.pixel_width(map)
        map.stagger_axis_y ?
          map.tile_width * map.width + map.tile_width / 2 :
          map.tile_width * (map.width + 1) / 2
      end
      
      def self.pixel_height(map)
        map.stagger_axis_y ?
          map.tile_height * (map.height + 1) / 2 :
          map.tile_height * map.height + map.tile_height / 2
      end
    end
  end
end
