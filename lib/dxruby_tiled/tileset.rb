module DXRuby
  module Tiled
    class Tileset
      attr_reader :firstgid, :source, :name, :tile_width, :tile_height,
                  :spacing, :margin, :tile_count, :columns, :tile_offset, :properties,
                  :tiles, :animations
      
      def initialize(data, map)
        @firstgid = data[:firstgid] || 1
        @source = data[:source]
        data_dir = @source ? File.dirname(@source) : map.data_dir
        data = map.load_tileset(@source) if @source
        
        @name        = data[:name]
        @tile_width  = data[:tilewidth]  || map.tile_width
        @tile_height = data[:tileheight] || map.tile_height
        @spacing     = data[:spacing]    || 0
        @margin      = data[:margin]     || 0
        @tile_count  = data[:tilecount]
        @columns     = data[:columns]
        @tile_offset = data[:tileoffset] || { x: 0, y: 0 }
        @properties  = data[:properties] || {}
        
        @tiles = []
        tile_images = []
        if data[:image]
          image = map.load_image(data[:image], data[:transparentcolor], data_dir)
          image_width  = data[:imagewidth]  || image.width
          image_height = data[:imageheight] || image.height
          tile_images = split_image(image, image_width, image_height)
          image.dispose()
        else
          data[:tiles].each_pair do |key, value|
            tile_images[key.to_s.to_i] = map.load_image(value[:image], nil, data_dir)
          end
        end
        @tile_count = tile_images.size unless @tile_count
        
        adjusted_offset_x = map.orientation == IsometricLayer ? map.tile_width / 2 : 0
        adjusted_offset_y = @tile_offset[:y] + map.tile_height
        tile_images.each_with_index do |image, i|
          next unless image
          @tiles[i] = Tile.new(
            image,
            @tile_offset[:x] - adjusted_offset_x,
            @tile_offset[:y], adjusted_offset_y - image.height,
            self
          )
        end
        
        tiles_data = data[:tiles] || {}
        set_types(tiles_data)
        set_animations(tiles_data)
        set_collisions(tiles_data)
      end
      
      def dispose()
        @tiles.each_value do |tile|
          @tile.image.dispose()
        end
      end
      
      def delayed_dispose()
        @tiles.each_value do |tile|
          @tile.image.delayed_dispose()
        end
      end
      
      def disposed?()
        @tiles[0].image.disposed?()
      end
      
      private
      
      def split_image(image, image_width, image_height)
        tile_images = []
        i = 0
        col = 1
        x = @margin
        y = @margin
        loop do
          if x + @tile_width > image_width || (@columns && col > @columns)
            x = @margin
            y += @tile_height + @spacing
            col = 1
          end
          break if y + @tile_height > image_height
          
          tile_images[i] = image.slice(x, y, @tile_width, @tile_height)
          x += @tile_width + @spacing
          i += 1
          col += 1
          break if @tile_count && i >= @tile_count
        end
        tile_images
      end
      
      def set_types(tiles_data)
        tiles_data.each_pair do |key, value|
          next unless value.has_key?(:type)
          @tiles[key.to_s.to_i].type = value[:type]
        end
      end
      
      def set_animations(tiles_data)
        @animations = []
        tiles_data.each_pair do |key, value|
          next unless value.has_key?(:animation)
          anim_time = [0]
          anim_tile = []
          value[:animation].each do |anim|
            anim_time.push(anim_time.last + anim[:duration])
            anim_tile.push(@tiles[anim[:tileid]])
          end
          @tiles[key.to_s.to_i].set_animation(anim_time, anim_tile)
          @animations.push(key.to_s.to_i)
        end
      end
      
      def set_collisions(tiles_data)
        tiles_data.each_pair do |key, value|
          next unless value.has_key?(:objectgroup)
          next unless value[:objectgroup].has_key?(:objects)
          collision = []
          value[:objectgroup][:objects].each do |obj|
            case
            when obj[:ellipse]
              collision.push([obj[:x], obj[:y], (obj[:width] + obj[:height]) / 2])
            when obj[:polygon]
              (obj[:polygon].size - 2).times do |i|
                collision.push([obj[:polygon][0    ][:x], obj[:polygon][0    ][:y],
                                obj[:polygon][i + 1][:x], obj[:polygon][i + 1][:y],
                                obj[:polygon][i + 2][:x], obj[:polygon][i + 2][:y]])
              end
            else
              collision.push([obj[:x], obj[:y], obj[:x] + obj[:width], obj[:y] + obj[:height]])
            end
          end
          @tiles[key.to_s.to_i].collision = collision
        end
      end
    end
  end
end
