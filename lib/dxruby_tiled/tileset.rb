module DXRuby
  module Tiled
    class Tileset
      attr_reader :firstgid, :name, :tile_width, :tile_height,
                  :spacing, :margin, :tile_count, :columns, :tile_offset, :properties,
                  :tile_images, :animations
      
      def initialize(data, map)
        @data = data
        @map  = map
        
        @firstgid    = data[:firstgid]  || 1
        @name        = data[:name]
        @tile_width  = data[:tilewidth]  || map.tile_width
        @tile_height = data[:tileheight] || map.tile_height
        @spacing     = data[:spacing]    || 0
        @margin      = data[:margin]     || 0
        @tile_count  = data[:tilecount]
        @columns     = data[:columns]
        @tile_offset = data[:tileoffset] # unsupported
        @properties  = data[:properties] || {}
        
        image = @map.load_image(data[:image])
        if data[:transparentcolor]
          color = data[:transparentcolor].sub("#", "").scan(/../).map{|c| c.to_i(16) }
          image.set_color_key(color)
        end
        image_width  = data[:imagewidth]  || image.width
        image_height = data[:imageheight] || image.height
        
        @tile_images = []
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
          
          @tile_images[i] = image.slice(x, y, @tile_width, @tile_height)
          x += @tile_width + @spacing
          i += 1
          col += 1
          break if @tile_count && i >= @tile_count
        end
        @tile_count = i unless @tile_count
        image.dispose()
        
        @animations = {}
        (data[:tiles] || {}).each_pair do |key, value|
          next unless value.has_key?(:animation)
          anim_time  = []
          anim_image = []
          time = 0
          value[:animation].each do |anim|
            anim_time.push(time)
            anim_image.push(@tile_images[anim[:tileid]])
            time += anim[:duration]
          end
          anim_time.push(time)
          @animations[@firstgid + key.to_s.to_i] = { time: anim_time, image: anim_image }
        end
      end
      
    end
  end
end
