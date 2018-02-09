module DXRuby
  module Tiled
    class TileLayer < Layer
      attr_reader :width, :height, :startx, :starty
      
      def initialize(data, map)
        super
        if data[:chunks]
          @x1 = data[:chunks].map {|chunk| chunk[:x] }.min
          @y1 = data[:chunks].map {|chunk| chunk[:y] }.min
          @x2 = data[:chunks].map {|chunk| chunk[:x] + chunk[:width ] }.max
          @y2 = data[:chunks].map {|chunk| chunk[:y] + chunk[:height] }.max
          @data = Array.new((@x2 - @x1) * (@y2 - @y1), 0)
          data[:chunks].each do |chunk|
            get_data(chunk[:data], data[:encoding], data[:compression]).each_with_index do |d, i|
              x, y = chunk[:x] + i % chunk[:width] - @x1, chunk[:y] + i / chunk[:width] - @y1
              @data[y * (@x2 - @x1) + x] = d
            end
          end
        else
          @x1 = data[:startx] || 0
          @y1 = data[:starty] || 0
          @x2 = @x1 + (data[:width ] || map.width )
          @y2 = @y1 + (data[:height] || map.height)
          @data = get_data(data[:data], data[:encoding], data[:compression])
        end
        @startx = @x1
        @starty = @y1
        @width  = @x2 - @x1
        @height = @y2 - @y1
        @tile_width  = map.tile_width
        @tile_height = map.tile_height
        @renderorder_x = map.renderorder_x
        @renderorder_y = map.renderorder_y
        @render_target = DXRuby::RenderTarget.new(DXRuby::Window.width, DXRuby::Window.height)
        @tilesets = map.tilesets
        
        self.extend LoopTileLayer if map.loop
      end
      
      def [](x, y)
        x < @x1 || x >= @x2 || y < @y1 || y >= @y2 ?
          0 : @data[(y - @y1) * @width + x - @x1]
      end
      
      def []=(x, y, value)
        return if x < @x1 || x >= @x2 || y < @y1 || y >= @y2
        @data[(y - @y1) * @width + x - @x1] = value
      end
      
      def include?(x, y)
        x >= @x1 && x < @x2 && y >= @y1 && y < @y2
      end
      alias_method :member?, :include?
      
      def at(pos_x, pos_y)
        x, y = xy_at(pos_x, pos_y)
        self[x, y]
      end
      
      def change_at(pos_x, pos_y, value)
        x, y = xy_at(pos_x, pos_y)
        self[x, y] = value
      end
      
      def tile_at(pos_x, pos_y)
        @tilesets[at(pos_x, pos_y)]
      end
      
      def render(pos_x, pos_y, target = DXRuby::Window, z = 0, offset_x = 0, offset_y = 0, opacity = 1.0)
        unless @render_target.width == target.width && @render_target.height == target.height
          @render_target.resize(target.width, target.height)
        end
      end
      alias_method :draw, :render
    
      private
    
      def get_data(data, encoding, compression)
        case encoding
        when "base64"
          tmp = Base64.decode64(data)
          case compression
          when "gzip" # unsupported
            raise NotImplementedError.new("GZip is unsupported.")
          when "zlib"
            data_array = Zlib::Inflate.inflate(tmp).unpack("L*")
          else
            data_array = tmp.unpack("L*")
          end
        else
          data_array = data
        end
        data_array
      end
    end
    
    module LoopTileLayer
      def [](x, y)
        @data[((y - @y1) % @height) * @width + ((x - @x1) % @width)]
      end
      
      def []=(x, y, value)
        @data[((y - @y1) % @height) * @width + ((x - @x1) % @width)] = value
      end
      
      def include?(x, y)
        true
      end
      
      def member?(x, y)
        true
      end
    end
  end
end
