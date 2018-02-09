# DXRuby::Tiled

[DXRuby](http://dxruby.osdn.jp/) を用いて、[Tiled Map Editor](http://www.mapeditor.org/) のデータを描画するライブラリです。


## インストール

    $ gem install dxruby_tiled

## 使用方法

    require "dxruby_tiled"
    
    pos_x, pos_y = 0, 0
    map = DXRuby::Tiled.load("tiledmapeditorfile.tmx")
    
    Window.loop do
      map.draw(pos_x, pos_y)
    end

詳しくは、 examples/dxruby_tiled_test.rb 等をご参照あれ。

## カスタムプロパティ

- map - loop
-- ループするマップになります。
- layer - fixed
-- スクロールしない固定表示になります。
- imagelayer - x_loop, y_loop
-- x方向、y方向に関して画像をループ表示します。

## サポート状況

### サポート済

- タイルレイヤー（□型、◇型、六角形型）
- オブジェクトレイヤー
- 当たり判定
- 画像レイヤー
- タイルのアニメーション

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nodai2hITC/dxruby_tiled.

## ライセンス

[MIT License](http://opensource.org/licenses/MIT).

