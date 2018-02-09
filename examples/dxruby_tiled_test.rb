require "dxruby_tiled"

puts <<'EOS'
usage: ruby dxruby_tiled_test.rb (TiledMapEditorFile) (width) (height) (scale)
  
  CURSOR KEY : move
  LEFT_SHIFT : speed down
  RIGHT_SHIFT: speed up
  M          : show/hidden the tile on mouse
  L          : show/hidden layers
  I          : show/hidden information
  S          : save screenshot
  P          : start pry
  ESCAPE     : exit
EOS

filename = ARGV[0] || Window.open_filename([["JSON file(*.json)", "*.json"], ["TMX file(*.tmx)", "*.tmx"]], "Select json|tmx file of TiledMapEditor")
exit unless filename

map = Tiled.load(filename)
Window.width  = ARGV[1].to_i if ARGV[1]
Window.height = ARGV[2].to_i if ARGV[2]
Window.scale  = ARGV[3].to_i if ARGV[3]

pos_x, pos_y = 0, 0
draw_mousetile   = true
draw_layers      = true
draw_information = true

font = Font.new(16)

selected_image = Image.new(32, 32, [128, 128, 128, 255])
selected_layer = map.layers.find { |layer| layer.is_a?(DXRuby::Tiled::TileLayer) }

tilelayer_image   = Image.load_from_file_in_memory(Base64.decode64(<<'EOS'
iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgI
fAhkiAAAAAlwSFlzAAAN1wAADdcBQiibeAAAABl0RVh0U29mdHdhcmUAd3d3
Lmlua3NjYXBlLm9yZ5vuPBoAAABSSURBVDiN7ZOxDYBADAMviJ1gDJiHFuZh
DBiBVaiOjhrk9iOlcGErPimlkkwXuYEeYJy332ec+1IAqAzT6nHd737RKmpe
IQ4otTFoDGIGlb7zA0m5s1NGNVw4AAAAAElFTkSuQmCC
EOS
))
objectgroup_image = Image.load_from_file_in_memory(Base64.decode64(<<'EOS'
iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgI
fAhkiAAAAAlwSFlzAAAN1wAADdcBQiibeAAAABl0RVh0U29mdHdhcmUAd3d3
Lmlua3NjYXBlLm9yZ5vuPBoAAAInSURBVDiNhZLBaxNBFMa/mZ3NzLamFJIe
EuqmlTQR+i8Ie+hWaLGgB2+CB08BvagHJVARSSvYg7dcrCB48CCSHr00NRQE
L0KxVNxCc4siBLw0O5udHQ/thhi3+p0eb9778X2PIVprAEClWM1yztfDMLyh
lBI4lRDiwPf9h/XD2hYSRGLAnYuP1mcKhbtLS0upiYkJAIDWGt88D41GoxeG
Ya5+WPs1CqBxYRjGTcdxBssAQAhBuVTC+enpEMBykgMWF1rrlGVZSTMQQqQp
pa9ul1dfAgClVBJC3gRB8JgND8ZxRmUwhsuLi+b8/LwJAL7viw+t1i3P89KD
CJSQT57n/UVQSqHdbsO2bQghIITA5OQk3IUF1u/3rw8c+FI+2W42L33Z3z+X
yWQIARBpjfbREWZmZzE1NfUHeHx8HFEUmWTYdqVY5Yyxn47jpMcsCyAE+VwO
2Ww2MVptbe3kiJViNY2TK1uGYfQLto1cLpe4FOv4+BiU0tD48bp/lTH20bbt
K/l8fllrbXU6HcO2bXDOz1xu7uyobrf7jnHOn66srIyVSyWcXhi7u7t4sbmJ
Xq+XCKCU9k3TfCulfMCklOXS3NzgUQgB13Xhum7i8rONjV4QBBee769+B05/
IiHkn3mHNTpLCSHqLKujUkpBhaEBIBgAUqnU1nazGf0PEgQBWq0WmGl+rh/W
unGfSSnvfT04UHt7e9eiKGJnAQghEef8ve/794f7vwF7CtF64Q/xTAAAAABJ
RU5ErkJggg==
EOS
))
imagelayer_image  = Image.load_from_file_in_memory(Base64.decode64(<<'EOS'
iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/
AP+gvaeTAAAACXBIWXMAAAsRAAALEQF/ZF+RAAAAB3RJTUUH3AsPDAQNlVwX
bgAAAfVJREFUOMudk0trU0EUx39z781NbvMwaRKaPoImatPgQnyBWlAEv4Qb
92IR6qpfQBALgi4U3IjfQBSMuhNcCCIISh4LpYW0GNNXTNLcR2faRWxtNYXU
gYEzB+Z3/vM/Z8Tde3fwmSae63KQZfr9bEgXDdj8z/0duGwkEkkuXphkIpdH
StlXdV3XKVdKmddvC0+NpaU6E7k8Dx7ex3GdvgCWZXFrapoXL59nDAApJY7r
8PXzR9rtDrbtEI9HEUL0BJw4eXYnNrYDIWA4opBBH42mR6Pxg9ihENHIAM1W
h+CAH03T/oEZuw9Doa4HqXAATbOo1hqUywscHokxHDFxXIe5xVXi2X0AqfAf
Eyvzq5zKRqnV6pzPRQAJCObm13srEEDqt4J1e4PTGYsPxQXCptrJO67EwNsD
2POo0UHFWFIxntbIjepcu5Sk+vMXdruJ22nxrFDh+pWh/T3ITJ7DiGXYWK7g
LFZQzQ6Pbxzn5qMyntzkyVSeYEDwrkrvLvjTV0Fo6KEsvnAE9e09IdPHmaNB
hBCMRLcHtwdASkm79qVLAmTHY60uwVYsNRUrLY/Fte5lqdRegK7rKKWYmS3+
1eVjXXVHxokDs5+62bH0LgWD8TjlSonb0zPYtt3XKAesAKVyEZ9pYqwsL1N4
8+rA3zmRTOK5Llttt8XxvDkmFQAAAABJRU5ErkJggg==
EOS
))
grouplayer_image  = Image.load_from_file_in_memory(Base64.decode64(<<'EOS'
iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAMUlEQVR4nGNg
GB5As2FnExD/R8MgMUt8GNmAeVgMIISb4AZ4rXvxnxw8asDwMmBoAwAE/3w0
rfjXvAAAAABJRU5ErkJggg==
EOS
))
visible_image  = Image.load_from_file_in_memory(Base64.decode64(<<'EOS'
iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAABHNCSVQICAgI
fAhkiAAAAAlwSFlzAAAM6wAADOsB5dZE0gAAABl0RVh0U29mdHdhcmUAd3d3
Lmlua3NjYXBlLm9yZ5vuPBoAAAAZdEVYdFRpdGxlAElua3NjYXBlIEljb24g
VGhlbWXo4pAiAAAAFXRFWHRBdXRob3IAQmFyYmFyYSBNdXJhdXMulXEFAAAB
t0lEQVQokZ2SMW/aUBSFz40fxsJSKoGXbpaVdmTrUJmhSAxZGPkDgJBQZFaW
Lh34A6DKkiuB1NW/IFsZ7KEd2NvUuFJHHBGEa6s8v9epKWmiqsoZ7z1nOecD
Hil66NjpdNRarfYcAJIk+ez7/s9/BgeDQYWIXhPRhRDiFACI6EZK+RbAxPO8
H/eCvV7vTFXVSyGEZVmWNE2TACCOYxlFEWma9j3Lslee5329DQ6HQwvAR8Mw
qt1ulyqVCsIwBADYto39fo/FYoHNZnMN4IXrupHiOM6pEOKDYRhPx+OxAgCT
yQTtdhu+72O5XKLVaqHZbGK1WpXSND2v1+vvTzjnc0VRzkajEdN1HWEYIs9z
+L6PLMuQ5zmCIICu63AchzHGnjHG3jEppSSie+3Gcfynwb/eREQnpVKpB+Db
bDaTaZrCtm1omnZr0jQNtm0jTVNMp9MD5/zqcDj0j8v5VK1Wn/T7fUXXdQRB
AABoNBrY7XaYz+c8SZJrInrpum50Z45yuXxZFIVlWRZM0wQArNdrGUURMcau
OOfnd+Y4BkBV1TdCiCHnXP8vAI71G7miKOR2u/3yEHKP1i+7XcWPCZS65wAA
AABJRU5ErkJggg==
EOS
))
hidden_image  = Image.load_from_file_in_memory(Base64.decode64(<<'EOS'
iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAABHNCSVQICAgI
fAhkiAAAAAlwSFlzAAAM6wAADOsB5dZE0gAAABl0RVh0U29mdHdhcmUAd3d3
Lmlua3NjYXBlLm9yZ5vuPBoAAAAZdEVYdFRpdGxlAElua3NjYXBlIEljb24g
VGhlbWXo4pAiAAAAFXRFWHRBdXRob3IAQmFyYmFyYSBNdXJhdXMulXEFAAAB
KElEQVQoke2QvUojYRiFn/clwgT/LiBgZRUVOys7BcG9ABc0hcV8qQKBIFgO
WIoXkNGpghYWC1tZyGLvHch2SgzYqIVEkG/ONilEyYK9T/2cc+DAN2OxZrN5
KGl+OBzu9Hq9l//JjUZjMkmSU3f/65IKYD1JkrMsy3xcKMsyr1arZ2a25u4n
bmZ14N7MNvv9/nWr1Zr5GAohzA4Ggz+SfgD3ZVkuWAhhzt1fy7K8AJYkPQPH
ZnYNYGYrkgIwBTwAqwAGkKbpkZk9AVfAJZB8GB2YWQHcAfVut9v2Uet+nucH
krYlddx9y8xugBz4FWNclPQzxvhb0h6AA+R5/jZqvq3VarmkaUnnlUqlAywX
RfEI7MYYy3fuZ9I03QghLI2OaYcQJsbKX+UfFzV3yJtNDmoAAAAASUVORK5C
YII=
EOS
))


Window.loop do
  d =  5
  d =  1 if Input.key_down?(K_LSHIFT)
  d = 20 if Input.key_down?(K_RSHIFT)
  if Input.key_down?(K_LCONTROL)
    pos_x -= d if Input.key_push?(K_LEFT)
    pos_x += d if Input.key_push?(K_RIGHT)
    pos_y -= d if Input.key_push?(K_UP)
    pos_y += d if Input.key_push?(K_DOWN)
  else
    pos_x += Input.x * d
    pos_y += Input.y * d
  end
  map.draw(pos_x, pos_y)
  
  mouse_x, mouse_y = pos_x + Input.mouse_x, pos_y + Input.mouse_y
  tile_x, tile_y = nil, nil
  
  # highlight selected tile
  if selected_layer.is_a?(Tiled::TileLayer)
    tile_x, tile_y = selected_layer.xy_at(mouse_x, mouse_y)
    vertexs = selected_layer.vertexs(tile_x, tile_y)
    if vertexs.size == 4
      Window.draw_morph(vertexs[0][0] - pos_x, vertexs[0][1] - pos_y,
                        vertexs[1][0] - pos_x, vertexs[1][1] - pos_y,
                        vertexs[2][0] - pos_x, vertexs[2][1] - pos_y,
                        vertexs[3][0] - pos_x, vertexs[3][1] - pos_y, selected_image)
    else
      Window.draw_morph(vertexs[0][0] - pos_x, vertexs[0][1] - pos_y,
                        vertexs[1][0] - pos_x, vertexs[1][1] - pos_y,
                        vertexs[2][0] - pos_x, vertexs[2][1] - pos_y,
                        vertexs[3][0] - pos_x, vertexs[3][1] - pos_y, selected_image)
      Window.draw_morph(vertexs[3][0] - pos_x, vertexs[3][1] - pos_y,
                        vertexs[4][0] - pos_x, vertexs[4][1] - pos_y,
                        vertexs[5][0] - pos_x, vertexs[5][1] - pos_y,
                        vertexs[0][0] - pos_x, vertexs[0][1] - pos_y, selected_image)
    end
  end
  
  # draw information
  draw_information = !draw_information if Input.key_push?(K_I)
  if draw_information
    Window.draw_box_fill(Window.width - 200, Window.height - 60, Window.width, Window.height, [192, 92, 92, 92])
    text1 = "(pos_x, pos_y) = (#{mouse_x}, #{mouse_y})"
    text2 = selected_layer.is_a?(Tiled::TileLayer) ? "[tile_x, tile_y] = [#{tile_x}, #{tile_y}]" : ""
    text3 = selected_layer.is_a?(Tiled::TileLayer) ? "tileid = #{selected_layer[tile_x, tile_y]}" : ""
    Window.draw_font(Window.width - 197 , Window.height - 57, text1, font, color: [0, 0, 0])
    Window.draw_font(Window.width - 197 , Window.height - 37, text2, font, color: [0, 0, 0])
    Window.draw_font(Window.width - 197 , Window.height - 17, text3, font, color: [0, 0, 0])
    Window.draw_font(Window.width - 198 , Window.height - 58, text1, font, color: [255, 255, 255])
    Window.draw_font(Window.width - 198 , Window.height - 38, text2, font, color: [255, 255, 255])
    Window.draw_font(Window.width - 198 , Window.height - 18, text3, font, color: [255, 255, 255])
  end
  
  # draw tile on mouse
  draw_mousetile = !draw_mousetile if Input.key_push?(K_M)
  if draw_mousetile && selected_layer.is_a?(Tiled::TileLayer)
    tile = map.tilesets[selected_layer[tile_x, tile_y]]
    Window.draw_box_fill(Window.width - tile.width - 8, 0, Window.width, tile.height + 8, [192, 92, 92, 92])
    Window.draw_ex(Window.width - tile.image.width - 4, 4, tile.image,
                   scale_x: tile.scale_x, scale_y: tile.scale_y, angle: tile.angle)
  end
  
  # draw layers
  draw_layers = !draw_layers if Input.key_push?(K_L)
  if draw_layers
    tmp_y = min_y = Window.height
    max_x = 0
    get_max_x_proc = Proc.new do |layers, x|
      layers.each do |layer|
        get_max_x_proc.call(layer, x + 20) if layer.is_a? DXRuby::Tiled::GroupLayer
        tmp_max_x = x + font.get_width(layer.name.to_s) + 36
        max_x = tmp_max_x if max_x < tmp_max_x
        min_y -= 20
      end
    end
    get_max_x_proc.call(map.layers, 2)
    Window.draw_box_fill(0, min_y, max_x, Window.height, [192, 92, 92, 92])
    
    draw_layer_proc = Proc.new do |layers, x|
      layers.each do |layer|
        draw_layer_proc.call(layer, x + 20) if layer.is_a? DXRuby::Tiled::GroupLayer
        tmp_y -= 20
        text_width = font.get_width(layer.name.to_s)
        if selected_layer == layer
          Window.draw_box_fill(x + 19, tmp_y + 2, x + text_width + 35, tmp_y + 18, [192, 92, 92, 255])
        end
        Window.draw(x + 19, tmp_y + 2,
          case layer
          when DXRuby::Tiled::TileLayer;   tilelayer_image
          when DXRuby::Tiled::ObjectGroup; objectgroup_image
          when DXRuby::Tiled::ImageLayer;  imagelayer_image
          when DXRuby::Tiled::GroupLayer;  grouplayer_image
          end
        )
        Window.draw_font(x + 37, tmp_y + 3, layer.name.to_s, font, color: [0, 0, 0])
        Window.draw_font(x + 36, tmp_y + 2, layer.name.to_s, font, color: [255, 255, 255])
        Window.draw(x + 2, tmp_y + 4, layer.visible ? visible_image : hidden_image)
        
        if Input.mouse_push?(M_LBUTTON) && ((tmp_y + 2)..(tmp_y + 18)).include?(Input.mouse_y)
          if ((x)..(x + 16)).include?(Input.mouse_x)
            layer.visible = !layer.visible
          end
          
          if ((x + 20)..(x + text_width + 1)).include?(Input.mouse_x)
            selected_layer = layer if layer.is_a?(DXRuby::Tiled::TileLayer)
          end
        end
      end
    end
    
    draw_layer_proc.call(map.layers, 2)
  end
  
  # save screenshot
  if Input.key_push?(K_S)
    Window.get_screen_shot("tmp", FORMAT_PNG)
    save_filename = Window.save_filename( [["PNG file(*.png)", "*.png"]], "ScreenShot filename")
    if save_filename
      save_filename << ".png" unless save_filename =~ /\.png$/
      File.rename("tmp", save_filename)
    else
      File.delete("tmp")
    end
  end
  
  Window.caption = "DXRuby_tiled - FPS:#{Window.real_fps} FILE:#{filename}"
  
  exit if Input.key_push?(K_ESCAPE)
  
  # start pry
  if Input.key_push?(K_P)
    require "pry"
    binding.pry
  end
end
