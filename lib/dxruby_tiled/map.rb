module DXRuby
  module Tiled
    class Map
      attr_reader   :data_dir, :tilesets, :layers,
                    :version, :tiledversion, :orientation, :renderorder_x, :renderorder_y,
                    :width, :height, :tile_width, :tile_height,
                    :hex_side_length, :stagger_axis_y, :stagger_index_odd,
                    :properties, :loop
      attr_accessor :background_color
      
      def initialize(data, data_dir)
        @data_dir = data_dir
        
        @version         = data[:version]
        @tiledversion    = data[:tiledversion]
        @orientation     =
          case data[:orientation]
          when "isometric" then IsometricLayer
          when "staggered" then StaggeredLayer
          when "hexagonal" then HexagonalLayer
          else                  OrthogonalLayer
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
        @loop              = !!@properties[:loop]
        @renderorder_x     = !data[:renderorder].to_s.match("left")
        @renderorder_y     = !data[:renderorder].to_s.match("top")
        @background_color = nil
        if data[:backgroundcolor]
          @background_color = data[:backgroundcolor].sub("#", "").scan(/../).map{ |c| c.to_i(16) }
        end
        
        @tilesets = Tilesets.new(data[:tilesets], self)
        @layers = GroupLayer.new({ layers: data[:layers] }, self)
      end
      
      def render(x, y, target = DXRuby::Window, z = 0)
        raise DXRuby::DXRubyError, "disposed object" if self.disposed?
        @tilesets.animate
        target.draw_box_fill(0, 0, target.width, target.height, @background_color, z) if @background_color
        @layers.render(x, y, target, z)
      end
      alias_method :draw, :render
      
      def pixel_width
        @orientation.pixel_width(self)
      end
      
      def pixel_height
        @orientation.pixel_height(self)
      end
      
      def next_object_id
        @next_object_id += 1
        return @next_object_id - 1
      end
      
      def dispose
        @tilesets.dispose
      end
      
      def delayed_dispose
        @tilesets.delayed_dispose
      end
      
      def disposed?
        @tilesets.disposed?
      end
      
      def load_image(filename, transparentcolor = nil, data_dir = @data_dir)
        image = DXRuby::Image.load(File.join(data_dir, filename))
        if transparentcolor
          color = transparentcolor.sub("#", "").scan(/../).map { |c| c.to_i(16) }
          image.set_color_key(color)
        end
        image
      end
      
      def load_tileset(filename, encoding = Encoding::UTF_8, data_dir = @data_dir)
        filepath = File.join(data_dir, filename)
        case File.extname(filename)
        when ".tsx", ".xml"
          DXRuby::Tiled::TMXLoader.tsx_to_hash(DXRuby::Tiled::TMXLoader.read_xmlfile(filepath, encoding))
        else
          DXRuby::Tiled.read_jsonfile(filepath, encoding)
        end
      end
      
      def load_template(filename, encoding = Encoding::UTF_8, data_dir = @data_dir)
        filepath = File.join(data_dir, filename)
        case File.extname(filename)
        when ".tx", ".xml"
          DXRuby::Tiled::TMXLoader.tx_to_hash(DXRuby::Tiled::TMXLoader.read_xmlfile(filepath, encoding))
        else
          DXRuby::Tiled.read_jsonfile(filepath, encoding)
        end
      end
    end
  end
end
