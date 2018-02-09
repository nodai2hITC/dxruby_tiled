require "dxruby" unless defined? DXRuby
require "json"   unless defined? JSON
require "zlib"   unless defined? Zlib
require "base64" unless defined? Base64
require "dxruby_tiled/version"
require "dxruby_tiled/map"
require "dxruby_tiled/tile"
require "dxruby_tiled/tileset"
require "dxruby_tiled/tilesets"
require "dxruby_tiled/layer"
require "dxruby_tiled/tilelayer"
require "dxruby_tiled/layer_orthogonal"
require "dxruby_tiled/layer_isometric"
require "dxruby_tiled/layer_staggered"
require "dxruby_tiled/layer_hexagonal"
require "dxruby_tiled/object"
require "dxruby_tiled/objectgroup"
require "dxruby_tiled/imagelayer"
require "dxruby_tiled/grouplayer"

module DXRuby
  module Tiled
    module_function
    autoload :TMXLoader, "dxruby_tiled/tmx_loader"
    
    def load(file, encoding = Encoding::UTF_8, dir = nil)
      case File.extname(file)
      when ".tmx", ".xml"
        TMXLoader.load_tmx(file, encoding, dir)
      else
        load_json(file, encoding, dir)
      end
    end
    
    def read_file(file, encoding = Encoding::UTF_8)
      File.read(file, encoding: encoding)
    end
    
    def load_json(jsonfile, encoding = Encoding::UTF_8, dir = nil)
      Map.new(read_jsonfile(jsonfile, encoding), dir || File.dirname(jsonfile))
    end
    
    def read_jsonfile(jsonfile, encoding = Encoding::UTF_8)
      JSON.parse(
        read_file(jsonfile, encoding),
        symbolize_names: true, create_additions: false
      )
    end
  end
end
