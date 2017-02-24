require "dxruby_tiled"

puts "DXRuby::tiled example - ver 1.0.0"
if ARGV[0] == "--help" || ARGV[0] == "-h"
  puts "  usage: ruby dxruby_tiled_test.rb [jsonfile] [WindowWidth] [WindowHeight]"
  exit
end
puts "Arrow Key: move (pressing the Shift key, slowly move)"
puts "M: Display the mouseover tile."
puts "L: Display layers."

filename = ARGV[0] || Window.open_filename([["JSONファイル(*.json)", "*.json"]], "Tiled Map Editor の JSON ファイルを選択")
exit unless filename

map = DXRuby::Tiled.load_json(filename)
Window.width  = ARGV[1].to_i if ARGV[1]
Window.height = ARGV[2].to_i if ARGV[2]

x, y = 0, 0
draw_mouseovertile = true
draw_layers        = false

font = Font.new(16)

mouseover_image = Image.new(32, 32, [128,128,128,255])

max_tile_width  = map.tilesets.tile_images.max{|image| image.width  }.width
max_tile_height = map.tilesets.tile_images.max{|image| image.height }.height

Window.loop do
  x += Input.x * (!Input.key_down?(K_LSHIFT) ? 5 : 1)
  y += Input.y * (!Input.key_down?(K_LSHIFT) ? 5 : 1)
  map.draw(x, y)
  
  tilelayer = map.layers.find{|layer| layer.is_a? DXRuby::Tiled::Layer }
  pos_x, pos_y = tilelayer.xy_at(x + Input.mouse_x, y + Input.mouse_y)
  vertexs = tilelayer.vertexs(pos_x, pos_y)
  if vertexs.size == 4
    Window.draw_morph(vertexs[0][0] - x, vertexs[0][1] - y,
                      vertexs[1][0] - x, vertexs[1][1] - y,
                      vertexs[2][0] - x, vertexs[2][1] - y,
                      vertexs[3][0] - x, vertexs[3][1] - y, mouseover_image)
  else
    Window.draw_morph(vertexs[0][0] - x, vertexs[0][1] - y,
                      vertexs[1][0] - x, vertexs[1][1] - y,
                      vertexs[2][0] - x, vertexs[2][1] - y,
                      vertexs[3][0] - x, vertexs[3][1] - y, mouseover_image)
    Window.draw_morph(vertexs[3][0] - x, vertexs[3][1] - y,
                      vertexs[4][0] - x, vertexs[4][1] - y,
                      vertexs[5][0] - x, vertexs[5][1] - y,
                      vertexs[0][0] - x, vertexs[0][1] - y, mouseover_image)
  end
  
  draw_mouseovertile = !draw_mouseovertile if Input.key_push?(K_M)
  if draw_mouseovertile
    Window.draw_box_fill(Window.width - max_tile_width - 8, 0, Window.width, max_tile_height + 8, [92,92,92])
    image = map.tilesets.tile_images[tilelayer[pos_x, pos_y]]
    Window.draw(Window.width  - max_tile_width  / 2 - image.width  / 2 - 4,
                                max_tile_height / 2 - image.height / 2 + 4, image)
  end
  
  draw_layers = !draw_layers if Input.key_push?(K_L)
  if draw_layers
    tmp_y = Window.height
    map.layers.each do |layer|
      tmp_y -= 20
      Window.draw_font(23 , tmp_y + 1, layer.name.to_s, font, color: [0,0,0])
      Window.draw_font(22 , tmp_y, layer.name.to_s, font)
      Window.draw_box_fill(2, tmp_y + 2, 18, tmp_y + 18, [255,255,255])
      Window.draw_box_fill(3, tmp_y + 3, 17, tmp_y + 17, [0,0,0])
      
      if layer.visible
        Window.draw_circle_fill(10, tmp_y + 10, 6, [255,255,255])
      end
      if Input.mouse_push?(M_LBUTTON) && Input.mouse_x >= 2 && Input.mouse_x <= 18 && Input.mouse_y >= tmp_y+2 && Input.mouse_y <= tmp_y+18
        layer.visible = !layer.visible
      end
    end
    
  end
  
  Window.caption = "DXRuby_tiled - FPS:#{Window.real_fps} FILE:#{filename}"
end
