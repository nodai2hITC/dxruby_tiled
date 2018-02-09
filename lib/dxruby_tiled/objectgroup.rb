module DXRuby
  module Tiled
    class ObjectGroup < Layer
      attr_reader :x, :y, :width, :height, :draworder, :objects
      
      def initialize(data, map)
        super
        @x         = data[:x]         || 0
        @y         = data[:y]         || 0
        @width     = data[:width ]    || map.width
        @height    = data[:height]    || map.height
        @draworder = data[:draworder] || "topdown"
        
        @render_target = DXRuby::RenderTarget.new(DXRuby::Window.width, DXRuby::Window.height)
        @objects = data[:objects].map do |object_hash|
          object = TMEObject.create_from_hash(object_hash, map)
          object.target = @render_target
          if object.is_a? TileObject
            object.scale_x = 1.0 * object_hash[:width ] / object.image.width  * object.scale_x
            object.scale_y = 1.0 * object_hash[:height] / object.image.height * object.scale_y
          end
          object
        end
      end
      
      def render(x, y, target = DXRuby::Window, z = 0, offset_x = 0, offset_y = 0, opacity = 1.0)
        if @render_target.width != target.width || @render_target.height != target.height
          @render_target.resize(target.width, target.height)
        end
        @render_target.ox = offset_x + @offset_x + (@fixed ? 0 : x)
        @render_target.oy = offset_y + @offset_y + (@fixed ? 0 : y)
        
        DXRuby::Sprite.update(@objects)
        DXRuby::Sprite.clean(@objects)
        DXRuby::Sprite.draw(
          case @draworder
          when "topdown" then @objects.sort_by { |obj| obj.y }
          when "index"   then @objects.sort_by { |obj| obj.object_id }
          else @objects
          end
        )
        target.draw_alpha(0, 0, @render_target, @opacity * 255, z + @z_index)
      end
      alias_method :draw, :render
    end
  end
end
