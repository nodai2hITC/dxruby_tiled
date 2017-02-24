module DXRuby
  module Tiled
    class Map
      attr_reader   :data_dir, :tilesets, :layers,
                    :version, :orientation, :renderorder_x, :renderorder_y,
                    :width, :height, :tile_width, :tile_height,
                    :hex_side_length, :stagger_axis_y, :stagger_index_odd,
                    :next_object_id, :properties, :x_loop, :y_loop
      attr_accessor :background_color
      
      def initialize(data, data_dir)
        @data_dir = data_dir
        
        @version         = data[:version]
        @orientation     = case data[:orientation]
          when "isometric"
            IsometricLayer
          when "staggered"
            StaggeredLayer
          when "hexagonal"
            HexagonalLayer
          else
            OrthogonalLayer
          end
        @width             = data[:width]         || 100
        @height            = data[:height]        || 100
        @tile_width        = data[:tilewidth]     || 32
        @tile_height       = data[:tileheight]    || 32
        @hex_side_length   = data[:hexsidelength] || 0
        @stagger_axis_y    = data[:staggeraxis]  != "x"
        @stagger_index_odd = data[:staggerindex] != "even"
        @next_object_id    = data[:nextobjectid]  || 1
        @properties        = data[:properties]    || {}
        @x_loop            = !!@properties[:x_loop]
        @y_loop            = !!@properties[:y_loop]
        @renderorder_x     = false
        @renderorder_y     = false
        case data[:renderorder]
        when "left-down"
          @renderorder_x = true
        when "right-up"
          @renderorder_y = true
        when "left-up"
          @renderorder_x = true
          @renderorder_y = true
        end
        @background_color = nil
        if data[:backgroundcolor]
          @background_color = data[:backgroundcolor].sub("#", "").scan(/../).map do |color|
            color.to_i(16)
          end
        end
        
        @layers = data[:layers].map do |layer|
          case layer[:type]
          when "tilelayer"
            @orientation.new(layer, self)
          when "objectgroup"
            ObjectGroup.new(layer, self)
          when "imagelayer"
            ImageLayer.new(layer, self)
          end
        end
        def @layers.name(name)
          return self.find{|layer| layer.name == name}
        end
        
        @tilesets = Tilesets.new(data[:tilesets], self)
      end
      
      def draw(x, y, target = DXRuby::Window)
        target.draw_box_fill(0, 0, target.width, target.height, @background_color) if @background_color
        tilesets.animation()
        @layers.each{|layer| layer.draw(x, y, target) if layer.visible }
      end
      
      def load_image(filename)
        return DXRuby::Image.load(File.join(@data_dir, filename))
      end
      
      def pixel_width()
        return @orientation.pixel_width(self)
      end
      
      def pixel_height()
        return @orientation.pixel_height(self)
      end
      
    end
  end
end
