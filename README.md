# DXRuby::Tiled

DXRuby::Tiled is a ruby library that draw [Tiled Map Editor](http://www.mapeditor.org/) data by using [DXRuby](http://dxruby.osdn.jp/)


## Install

    $ gem install dxruby_tiled

	
## How to use

    require "dxruby_tiled"
    
    pos_x, pos_y = 0, 0
    map = DXRuby::Tiled.load("tiledmapeditorfile.tmx")
    
    Window.loop do
      map.draw(pos_x, pos_y)
    end

For more information, examples/dxruby_tiled_test.rb


## Custom properties

- map - loop(bool)
- layer - fixed(bool)
- imagelayer - x_loop, y_loop(bool)

## Support status

### Supported

- tile layer (orthogonal, isometric, staggered, hexagonal)
- image layer
- object layer
- collision
- animation

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nodai2hITC/dxruby_tiled.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

