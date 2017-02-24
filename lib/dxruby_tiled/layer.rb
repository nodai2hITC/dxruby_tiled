module DXRuby
  module Tiled
    class Layer
      attr_reader   :data, :name, :width, :height, :properties
      attr_accessor :opacity, :visible, :offset_x, :offset_y
      
      def initialize(data, map)
        @map = map
        
        @name       = data[:name]
        @width      = data[:width ]     || map.width
        @height     = data[:height]     || map.height
        @opacity    = data[:opacity]    || 1.0
        @visible    = data[:visible] != false
        @offset_x   = data[:offsetx]    || 0
        @offset_y   = data[:offsety]    || 0
        @properties = data[:properties] || {}
        
        case data[:encoding]
        when "base64"
          tmp = Base64.decode64(data[:data])
          case data[:compression]
          when "gzip" # unsupported
          when "zlib"
            tmp = Zlib::Inflate.inflate(tmp).unpack("l*")
          else
            tmp = tmp.unpack("l*")
          end
        else
          tmp = data[:data]
        end
        @data = tmp.each_slice(@width).to_a
      end
      
      def [](x, y)
        x = @map.x_loop ? x % @width  : x < 0 ? @width  : x
        y = @map.y_loop ? y % @height : y < 0 ? @height : y
        return @data.fetch(y, []).fetch(x, 0)
      end
      
      def []=(x, y, value)
        x = @map.x_loop ? x % @width  : x < 0 ? @width  : x
        y = @map.y_loop ? y % @height : y < 0 ? @height : y
        @data[y][x] = value
      end
      
      def include?(x, y)
        return (@map.x_loop || (0...@width).include?(x)) &&
                (@map.y_loop || (0...@height).include?(y))
      end
      alias_method :member?, :include?
      
    end
  end
end
