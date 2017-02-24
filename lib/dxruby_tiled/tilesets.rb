module DXRuby
  module Tiled
    class Tilesets
      attr_reader :tile_images
      
      def initialize(data, map)
        @data = data
        @map  = map
        
        @last_time = 0
        @tile_images = [DXRuby::Image.new(32, 32)]
        @tilesets = @data.map{|tileset| Tileset.new(tileset, @map)}
        @animations = {}
        
        @tilesets.each do |tileset|
          gid = tileset.firstgid || @tile_images.size
          tileset.tile_images.each_index{|i| @tile_images[gid + i] = tileset.tile_images[i] }
          @animations.merge!(tileset.animations)
        end
      end
      
      def animation()
        return if @last_time == DXRuby::Window::running_time
        @last_time = DXRuby::Window::running_time
        
        @animations.each_pair do |key, anim|
          time = @last_time % anim[:time].last
          @tile_images[key] = anim[:image][anim[:time].rindex{|t| time >= t }]
        end
      end
      
    end
  end
end
