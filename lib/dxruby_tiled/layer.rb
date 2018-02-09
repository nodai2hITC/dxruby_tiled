module DXRuby
  module Tiled
    class Layer
      attr_reader   :name, :properties
      attr_accessor :opacity, :visible, :offset_x, :offset_y, :z_index
      
      def self.create(data, map)
        case data[:type]
        when "tilelayer"
          map.orientation.new(data, map)
        when "objectgroup"
          DXRuby::Tiled::ObjectGroup.new(data, map)
        when "imagelayer"
          DXRuby::Tiled::ImageLayer.new(data, map)
        when "group"
          DXRuby::Tiled::GroupLayer.new(data, map)
        end
      end
      
      def initialize(data, map)
        @name       = data[:name]
        @opacity    = data[:opacity]    || 1.0
        @visible    = data[:visible] != false
        @offset_x   = data[:offsetx]    || 0
        @offset_y   = data[:offsety]    || 0
        @properties = data[:properties] || {}
        @z_index    = @properties[:z_index] || 0
        @fixed      = !!@properties[:fixed]
      end
    end
  end
end
