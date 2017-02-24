require "dxruby"
require "json"
require "zlib"
require "base64"
require "dxruby_tiled/version"
require "dxruby_tiled/map"
require "dxruby_tiled/tilesets"
require "dxruby_tiled/tileset"
require "dxruby_tiled/layer"
require "dxruby_tiled/layer_orthogonal"
require "dxruby_tiled/layer_isometric"
require "dxruby_tiled/layer_staggered"
require "dxruby_tiled/layer_hexagonal"
require "dxruby_tiled/objectgroup" # unsupported
require "dxruby_tiled/imagelayer"

module DXRuby
  module Tiled
    def self.load_json(jsonfile, encoding = "UTF-8", dir = nil)
      return Map.new(JSON.load(File.read(jsonfile, encoding: encoding), nil,
                                symbolize_names: true, create_additions: false),
                      dir || File.dirname(jsonfile))
    end
  end
end
