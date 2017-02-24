# DXRuby::Tiled

[DXRuby](http://dxruby.osdn.jp/) を用いて、[Tiled Map Editor](http://www.mapeditor.org/) のデータを描画するライブラリです。


## インストール

    $ gem install dxruby_tiled

	
## 使用方法

    require "dxruby_tiled"
    
    x, y = 0, 0
    map = DXRuby::Tiled.load_json("tiledmapeditorfile.json")
    
    Window.loop do
    map.draw(x, y)
    end

詳しくは、 examples/dxruby_tiled_test.rb 等をご参照あれ。


## カスタムプロパティ

- map - x_loop, y_loop
-- x方向、y方向に関してループするマップになります。
- imagelayer - fixed
-- スクロールしない固定表示になります。

## サポート状況

### サポート済

- タイルレイヤー（□型、◇型、六角形型）
- 画像レイヤー
- タイルのアニメーション

### サポート予定

- オブジェクトレイヤー
- 当たり判定

### サポート予定なし

- TMX ファイルの読み込み


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/dxruby_tiled.


## ライセンス

[MIT License](http://opensource.org/licenses/MIT).

