module DXRuby
  module Tiled
    class ImageLayer
      attr_reader :data, :name, :properties
      attr_accessor :opacity, :visible, :offset_x, :offset_y, :fixed
      
      def initialize(data, map)
        @original_data = data
        @map = map
        
        @name       = data[:name]
        @opacity    = data[:opacity]    || 1.0
        @visible    = data[:visible] != false
        @offset_x   = data[:offsetx]    || 0
        @offset_y   = data[:offsety]    || 0
        @properties = data[:properties] || {}
        @fixed      = @properties[:fixed]
        
        @image      = @map.load_image(data[:image])
        if data[:transparentcolor]
          color = data[:transparentcolor].sub("#", "").scan(/../).map{|c| c.to_i(16) }
          @image.set_color_key(color)
        end
      end
      
      def draw(x, y, target = DXRuby::Window)
        x = (x + target.width)  % @map.pixel_width  - target.width  if @map.x_loop
        y = (y + target.height) % @map.pixel_height - target.height if @map.y_loop
        target.draw_alpha(@offset_x - (@fixed ? 0 : x), @offset_y - (@fixed? 0 : y),
                          @image, (255 * @opacity).to_i)
      end
      
    end
  end
end
