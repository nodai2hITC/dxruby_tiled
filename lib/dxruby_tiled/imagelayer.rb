module DXRuby
  module Tiled
    class ImageLayer < Layer
      attr_accessor :image, :fixed, :x_loop, :y_loop
      
      def initialize(data, map)
        super
        @x_loop = !!@properties[:x_loop]
        @y_loop = !!@properties[:y_loop]
        @image  = map.load_image(data[:image], data[:transparentcolor])
        @map_loop = map.loop
        @map_pixel_width  = map.pixel_width
        @map_pixel_height = map.pixel_height
      end
      
      def render(x, y, target = DXRuby::Window, z = 0, offset_x = 0, offset_y = 0, opacity = 1.0)
        x_range = 0..0
        if @x_loop
          x0 = (@offset_x + offset_x - (@fixed? 0 : x)) % @image.width
          x_range = -1..((target.width - 1) / @image.width)
        elsif @fixed
          x0 = @offset_x + offset_x
        elsif @map_loop
          x0 = (@offset_x + offset_x - x + target.width) % @map_pixel_width - target.width
        else
          x0 = @offset_x + offset_x - x
        end
        
        y_range = 0..0
        if @y_loop
          y0 = (@offset_y + offset_y - (@fixed? 0 : y)) % @image.height
          y_range = -1..((target.height - 1) / @image.height)
        elsif @fixed
          y0 = @offset_y + offset_y
        elsif @map_loop
          y0 = (@offset_y + offset_y - y + target.height) % @map_pixel_height - target.height
        else
          y0 = @offset_y + offset_y - y
        end
        
        x_range.each do |i_x|
          y_range.each do |i_y|
            target.draw_alpha(x0 + @image.width * i_x, y0 + @image.height * i_y,
                              @image, 255 * opacity * @opacity, z + @z_index)
          end
        end
      end
      alias_method :draw, :render
    end
  end
end
