module DXRuby
  module Tiled
    class ObjectGroup # unsupported
      attr_reader   :data, :name, :width, :height, :properties
      attr_accessor :opacity, :visible, :offset_x, :offset_y
      
      def initialize(data, map)
        @original_data = data
        @map = map
        
        @name       = data[:name]
        @color      = data[:color]      || [128, 128, 128]
        @opacity    = data[:opacity]    || 1
        @visible    = data[:visible] != false
        @offset_x   = data[:offsetx]    || 0
        @offset_y   = data[:offsety]    || 0
        @properties = data[:properties] || {}
        @draworder  = data[:draworder]  || "topdown"
      end
      
      def draw(x, y, target = DXRuby::Window)
      end

    end
  end
end
