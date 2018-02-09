module DXRuby
  module Tiled
    class TMEObject < DXRuby::Sprite
      attr_reader :object_id, :properties
      attr_accessor :name, :type
      
      def self.create_from_hash(hash, map = nil)
        hash[:id] ||= map.next_object_id
        if hash[:template]
          template = map.load_template(hash[:template])
          gid, source = template[:object][:gid], template[:tileset][:source]
          template[:object][:gid] = map.tilesets.gid_adjusted_by_source(gid, source)
          hash.merge!(template[:object])
        end
        object = case
        when hash[:point]
          PointObject.create_from_hash(hash)
        when hash[:ellipse]
          EllipseObject.create_from_hash(hash)
        when hash[:polygon]
          PolygonObject.create_from_hash(hash)
        when hash[:polyline]
          PolylineObject.create_from_hash(hash)
        when hash[:text]
          TextObject.create_from_hash(hash)
        when hash[:gid]
          hash[:tile] = map.tilesets[hash[:gid]]
          TileObject.create_from_hash(hash)
        else
          RectangleObject.create_from_hash(hash)
        end
        if map && map.orientation == IsometricLayer
          object.extend(ObjectInIsometricMap)
          object.width_height = 1.0 * map.tile_height / map.tile_width
        end
        object
      end
      
      def initialize(x, y, options = {})
        super x, y, nil
        @name        = options[:name]
        @type        = options[:type]
        @object_id   = options[:id]
        @width       = options[:width]
        @height      = options[:height]
        @properties  = options[:properties]
        self.angle   = options[:rotation]
        self.visible = options[:visible]
        self.collision_sync = true
      end
    end
    
    class PointObject < TMEObject
      def self.create_from_hash(hash)
        self.new(hash[:x], hash[:y], hash)
      end
      
      def initialize(x, y, width, height, options = {})
        super x, y, options
        self.collision = [0, 0]
      end
      
      def draw; end
    end
    
    class RectangleObject < TMEObject
      def self.create_from_hash(hash)
        self.new(hash[:x], hash[:y], hash[:width], hash[:height], hash)
      end
      
      def initialize(x, y, width, height, options = {})
        options[:width]  = width
        options[:height] = height
        super x, y, options
        self.collision = [0, 0, @width, @height]
      end
      
      def draw; end
    end
    
    class EllipseObject < TMEObject
      def self.create_from_hash(hash)
        self.new(hash[:x], hash[:y], hash[:width], hash[:height], hash)
      end
      
      def initialize(x, y, width, height, options = {})
        options[:width]  = width
        options[:height] = height
        super x, y, options
        self.collision = [@width / 2.0, @width / 2.0, @width / 2.0]
        self.scale_y = 1.0 * @height / @width
      end
      
      def draw; end
    end
    
    class PolygonObject < TMEObject
      def self.create_from_hash(hash)
        self.new(hash[:x], hash[:y], hash[:polygon], hash)
      end
      
      def initialize(x, y, vertexs, options)
        super x, y, options
        collision = []
        (vertexs.size - 2).times do |i|
          collision.push([vertexs[0    ][:x], vertexs[0    ][:y],
                          vertexs[i + 1][:x], vertexs[i + 1][:y],
                          vertexs[i + 2][:x], vertexs[i + 2][:y]])
        end
        self.collision = collision
      end
      
      def draw; end
    end
    
    class PolylineObject < TMEObject
      def self.create_from_hash(hash)
        self.new(hash[:x], hash[:y], hash[:polyline], hash)
      end
      
      def initialize(x, y, vertexs, options)
        super x, y, options
        collision = []
        (vertexs.size - 2).times do |i|
          collision.push([vertexs[0    ][:x], vertexs[0    ][:y],
                          vertexs[i + 1][:x], vertexs[i + 1][:y],
                          vertexs[i + 2][:x], vertexs[i + 2][:y]])
        end
        self.collision = collision
      end
      
      def draw; end
    end
    
    class TextObject < TMEObject
      attr_accessor :text
      
      def self.create_from_hash(hash)
        self.new(hash[:x], hash[:y], hash[:width], hash[:height], hash[:text][:text], hash[:text])
      end
      
      def initialize(x, y, width, height, text, options = {})
        options[:width]  = width
        options[:height] = height
        super x, y, options
        @text = text
        @fontfamily = options[:fontfamily] || ""
        @pixelsize  = options[:pixelsize] || 16
        @wrap       = !!options[:wrap] # unsupported
        @color      = (options[:color] || "000000").sub("#", "").scan(/../).map{ |c| c.to_i(16) }
        @bold       = !!options[:bold]
        @italic     = !!options[:italic]
        @underline  = !!options[:underline] # unsupported
        @strikeout  = !!options[:strikeout] # unsupported
        @kerning    = options[:kerning] != false # unsupported
        @halign     = options[:halign] || "left" # unsupported
        @valign     = options[:valign] || "top" # unsupported
        
        @font = DXRuby::Font.new(@pixelsize, @fontfamily,
          weight: @bold, italic: @italic, auto_fitting: true
        )
        self.collision = [0, 0, @width, @height]
      end
      
      def draw
        self.target.draw_font(self.x, self.y, @text, @font,
          color: @color, center_x: 0, center_y: 0, angle: self.angle, z: self.z
        )
      end
    end
    
    class TileObject < TMEObject
      attr_reader :tile
      attr_accessor :start_time
      
      def self.evolve(object)
        new_object = self.new(x: object.x, y: object.y, tile: object.tile, id: @object_id)
        %w[z angle scale_x scale_y center_x center_y 
           alpha blend shader image target
           collision collision_enable collision_sync visible offset_sync
           name type start_time].each do |arg|
          new_object.send(arg + "=", object.send(arg))
        end
      end
      
      def self.create_from_hash(hash)
        self.new(hash[:x], hash[:y], hash[:tile], hash)
      end
      
      def initialize(x, y, tile, options = {})
        super x, y, options
        @tile = tile
        self.image = tile.original_image
        if tile.is_a? FlippedTile
          self.scale_x = tile.scale_x
          self.scale_y = tile.scale_y
          @tile = tile.tile
          self.extend(FlippedTileObject)
        end
        self.angle    = options[:rotation]
        self.center_x = -tile.offset_x
        self.center_y = self.image.height - tile.offset_y
        self.collision = tile.collision
        self.collision_enable = tile.collision_enable
        self.offset_sync = true
        @start_time = nil
      end
      
      def draw
        @start_time ||= DXRuby::Window::running_time
        tile = @tile.animate((DXRuby::Window::running_time - @start_time))
        self.image    = tile.original_image
        self.center_x = -tile.offset_x
        self.center_y = self.image.height - tile.offset_y
        super
      end
      
      def tile=(tile)
        @tile = tile
        @start_time = nil
      end
      
      def become(new_class)
        new_class.evolve(self)
      end
    end
    
    module FlippedTileObject
      def draw
        @start_time ||= DXRuby::Window::running_time
        tile = @tile.animate((DXRuby::Window::running_time - @start_time))
        self.image = tile.original_image
        sin = Math.sin(2 * Math::PI * self.angle / 360)
        cos = Math.cos(2 * Math::PI * self.angle / 360)
        cx = (self.image.width  * 0.5 + tile.offset_x) * self.scale_x.abs
        cy = (self.image.height * 0.5 - tile.offset_y) * self.scale_y.abs
        x = self.x + cx * cos + cy * sin
        y = self.y - cy * cos + cx * sin
        self.target.draw_ex(x, y, self.image,
          scale_x:  self.scale_x,
          scale_y:  self.scale_y,
          alpha:    self.alpha,
          blend:    self.blend,
          angle:    self.angle,
          shader:   self.shader,
          z:        self.z,
          offset_sync: true
        )
      end
    end
    
    module ObjectInIsometricMap
      attr_accessor :width_height
      def draw
        tmp_x, tmp_y = self.x, self.y
        self.x = tmp_x - tmp_y
        self.y = (tmp_x + tmp_y) * @width_height
        super
        self.x, self.y = tmp_x, tmp_y
      end
    end
  end
end
