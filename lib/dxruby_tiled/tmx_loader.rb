require "dxruby_tiled"
require "rexml/document"

module DXRuby
  module Tiled
    module TMXLoader
      module_function
      
      def load_tmx(tmxfile, encoding = Encoding::UTF_8, dir = nil)
        Map.new(
          TMXLoader.tmx_to_hash(TMXLoader.read_xmlfile(tmxfile, encoding)),
          dir || File.dirname(tmxfile)
        )
      end
      
      def read_xmlfile(xmlfile, encoding = Encoding::UTF_8)
        REXML::Document.new(DXRuby::Tiled.read_file(xmlfile, encoding))
      end
      
      def element_to_hash(elm, attrs_i = [], attrs_f = [], attrs_b = [])
        hash = {}
        
        elm.attributes.each_pair do |key, value|
          str = value.to_s
          if attrs_i.include?(key)
            hash[key.to_sym] = str.to_i
          elsif attrs_f.include?(key)
            hash[key.to_sym] = str.to_f
          elsif attrs_b.include?(key)
            hash[key.to_sym] = !!str && str != "0" && str != "false"
          else
            hash[key.to_sym] = str
          end
        end
        
        hash
      end
      
      def properties_parent_to_hash(element)
        properties_hash = { properties: {}, propertytypes: {} }
        
        element.each_element("properties") do |properties|
          properties.each_element_with_attribute("type") do |property|
            name  = property.attribute("name" ).to_s.to_sym
            type  = property.attribute("type" ).to_s
            value = property.attribute("value").to_s
            case type
            when "string", "color", "file"
              properties_hash[:properties][name] = value
            when "int"
              properties_hash[:properties][name] = value.to_i
            when "float"
              properties_hash[:properties][name] = value.to_f
            when "bool"
              properties_hash[:properties][name] = !!value && value != "0" && value != "false"
            end
            properties_hash[:propertytypes][name] = type
          end
        end
        
        properties_hash[:properties].empty? ? {} : properties_hash
      end
      
      def tileset_to_hash(tileset_element)
        tileset_hash = element_to_hash(tileset_element,
          %w[firstgid tilewidth tileheight spacing margin tilecount columns]
        )
        tileset_hash.merge!(properties_parent_to_hash(tileset_element))
        tileset_element.each_element("tileoffset") do |tileoffset|
          tileset_hash[:tileoffset] = {
            x: tileoffset.attribute("x").to_s.to_i,
            y: tileoffset.attribute("y").to_s.to_i
          }
        end
        tileset_element.each_element("image") do |image_element|
          tileset_hash.merge!(image_to_hash(image_element))
        end
        tileset_hash[:tiles] = {}
        tileset_element.each_element("tile") do |tile_element|
          hash = element_to_hash(tile_element)
          tile_hash = { type: hash[:type] }
          tile_element.each_element("image") do |image_element|
            tile_hash.merge!(image_to_hash(image_element))
          end
          tile_element.each_element("objectgroup") do |objectgroup_element|
            tile_hash[:objectgroup] = objectgroup_to_hash(objectgroup_element)
          end
          tile_element.each_element("animation") do |animation_element|
            tile_hash[:animation] = animation_to_array(animation_element)
          end
          tileset_hash[:tiles][hash[:id]] = tile_hash
        end
        
        tileset_hash
      end
      
      def image_to_hash(image_element)
        hash = {}
        
        image_hash = element_to_hash(image_element, %w[width height])
        hash[:image]            = image_hash[:source] if image_hash.has_key?(:source)
        hash[:imagewidth]       = image_hash[:width ] if image_hash.has_key?(:width )
        hash[:imageheight]      = image_hash[:height] if image_hash.has_key?(:height)
        hash[:transparentcolor] = image_hash[:trans ] if image_hash.has_key?(:trans )
        
        hash
      end
      
      def objectgroup_to_hash(objectgroup_element)
        objectgroup_hash = element_to_hash(objectgroup_element,
          %w[x y width height offsetx offsety],
          %w[opacity],
          %w[visible]
        )
        objectgroup_hash.merge!(properties_parent_to_hash(objectgroup_element))
        objectgroup_hash[:objects] = []
        objectgroup_element.each_element("object") do |object_element|
          objectgroup_hash[:objects].push(object_to_hash(object_element))
        end
        
        objectgroup_hash
      end
      
      def object_to_hash(object_element)
        object_hash = { rotation: 0, visible: true }
        
        object_hash.merge!(element_to_hash(object_element,
          %w[id gid],
          %w[x y width height rotation opacity],
          %w[visible]
        ))
        object_hash.merge!(properties_parent_to_hash(object_element))
        object_hash[:ellipse] = true unless object_element.get_elements("ellipse").empty?
        object_hash[:point]   = true unless object_element.get_elements("point").empty?
        object_element.each_element("polygon") do |polygon_element|
          object_hash[:polygon] = polygon_element.attribute("points").to_s.split(" ").map do |point|
            x, y = point.split(",").map(&:to_f)
            { x: x, y: y }
          end
        end
        object_element.each_element("polyline") do |polyline_element|
          object_hash[:polyline] = polyline_element.attribute("points").to_s.split(" ").map do |point|
            x, y = point.split(",").map(&:to_f)
            { x: x, y: y }
          end
        end
        object_element.each_element("text") do |text_element|
          object_hash[:text] = element_to_hash(text_element,
            %w[pixelsize],
            %w[],
            %w[wrap bold italic underline strikeout kerning]
          )
          object_hash[:text][:text] = text_element.text
        end
        
        object_hash
      end
      
      def animation_to_array(animation_element)
        animations = []
        
        animation_element.each_element("frame") do |frame|
          animations.push({
            tileid:   frame.attribute("tileid"  ).to_s.to_i,
            duration: frame.attribute("duration").to_s.to_i
          })
        end
        
        animations
      end
      
      def layers_to_array(layers_parent_element)
        layers_array = []
        
        layers_parent_element.each_child do |layer_element|
          next unless layer_element.is_a?(REXML::Element)
          layer_hash = element_to_hash(layer_element,
            %w[x y width height offsetx offsety],
            %w[opacity],
            %w[visible]
          )
          layer_hash.merge!(properties_parent_to_hash(layer_element))
          
          case layer_element.name.to_s
          when "layer"
            layer_hash[:type] = "tilelayer"
            data = layer_element.get_elements("data").first
            data_hash = element_to_hash(data)
            layer_hash[:compression] = data_hash[:compression] if data_hash.has_key?(:compression)
            layer_hash[:encoding   ] = data_hash[:encoding   ] if data_hash.has_key?(:encoding   )
            chunks = data.get_elements("chunk")
            if chunks.empty?
              if layer_hash[:encoding] == "csv"
                layer_hash[:data] = data.text.strip.split(",").map(&:to_i)
              else
                layer_hash[:data] = data.text
              end
            else
              layer_hash[:chunks] = []
              chunks.each do |chunk|
                chunk_hash = element_to_hash(chunk, %w[x y width height])
                if layer_hash[:encoding] == "csv"
                  chunk_hash[:data] = chunk.text.strip.split(",").map(&:to_i)
                else
                  chunk_hash[:data] = chunk.text
                end
                layer_hash[:chunks].push(chunk_hash)
              end
            end
          when "objectgroup"
            layer_hash[:type] = "objectgroup"
            layer_hash.merge!(objectgroup_to_hash(layer_element))
          when "imagelayer"
            layer_hash[:type] = "imagelayer"
            layer_element.each_element("image") do |image_element|
              layer_hash.merge!(image_to_hash(image_element))
            end
          when "group"
            layer_hash[:type] = "group"
            layer_hash[:layers] = layers_to_array(layer_element)
          else
            next
          end
          layers_array.push(layer_hash)
        end
        
        layers_array
      end
      
      def tmx_to_hash(tmx)
        map_element = tmx.root
        hash = element_to_hash(map_element,
          %w[width height tilewidth tileheight hexsidelength nextobjectid],
          %w[version],
          %w[]
        )
        hash.merge!(properties_parent_to_hash(map_element))
        hash[:tilesets] = []
        map_element.each_element("tileset") do |tileset_element|
          hash[:tilesets].push(tileset_to_hash(tileset_element))
        end
        hash[:layers] = layers_to_array(map_element)
        
        hash
      end
      
      def tsx_to_hash(tsx)
        hash = tileset_to_hash(tsx.root)
        
        hash
      end
      
      def tx_to_hash(tx)
        hash = {}
        
        tx.root.each_element("tileset") do |tileset_element|
          hash[:tileset] = element_to_hash(tileset_element,
            %w[firstgid],
            %w[],
            %w[]
          )
        end
        tx.root.each_element("object") do |object_element|
          hash[:object] = object_to_hash(object_element)
        end
        
        hash
      end
    end
  end
end
