module DXRuby
  module Tiled
    class GroupLayer < Layer
      include Enumerable
      
      def initialize(data, map)
        super
        @layers = data[:layers].map do |layer|
          Layer.create(layer, map)
        end
      end
      
      def [](name)
        return @layers[name] if name.is_a? Integer
        return @layers.find { |layer| layer.name == name }
      end
      
      def each
        @layers.each { |layer| yield layer }
      end
      
      def render(x, y, target = DXRuby::Window, z = 0, offset_x = 0, offset_y = 0, opacity = 1.0)
        @layers.each do |layer|
          layer.render(x, y, target, z + @z_index, offset_x + @offset_x, offset_y + @offset_y, opacity * @opacity) if layer.visible
        end
      end
      alias_method :draw, :render
    end
  end
end
