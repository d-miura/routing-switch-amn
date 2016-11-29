# 第6回 (11/9)レポート1(team-amn:東野研)
## メンバー
* 今井 友揮
* 成元 椋祐
* 西村 友佑
* 原 佑輔
* 三浦 太樹

## 課題 (経路選択アルゴリズムの実装と可視化)

>* ルーティングスイッチのダイクストラ法を、別の経路選択アルゴリズムに置き換える
>  * 経路の重み (= リンクの太さ) などを導入してもいいです
>* コントローラの動作をブラウザで見れるように可視化する
>  * 選択した経路やアルゴリズムの動作が分かるように工夫してください

# 経路選択アルゴリズム

# ブラウザでの可視化
## Rubyプログラム内での動作
### 前回のプログラムの使用
TopologyControllerのクラスを前回作成したVis.jsで表示するプログラムを使用した．配布されたソースコードではTopologyControllerの実装は./vendorフォルダ内に入っていた．そのフォルダに前回作成したtopology-amnのプログラム一式を入れた．そして，そのプログラムを使用する為に[routing_switch.rb](./lib/routing_switch.rb)の一行目を以下のように変更した．

```
#$LOAD_PATH.unshift File.join(__dir__, '../vendor/topology/lib')
$LOAD_PATH.unshift File.join(__dir__, '../vendor/topology-amn/lib')
```
### javascriptファイルの出力
javascriptファイルにネットワークを出力する．まず，トポロジを出力する部分はTopologyController内の[/lib/view/vis.rb](./vendor/topology-amn/lib/view/vis.rb)で実装した．
スイッチのノードとエッジ，ホストのノードとエッジをそれぞれvis.js形式で出力する．出力するファイルは[/output/topology.js](./output/topology.js)とする．

以下に仮想スイッチで動作させた時のtopology.jsの例を示す．

```
var nodes = null;
var edges = null;
var network = null;
nodes = [];
// Create a data table with links.
edges = [];
var DIR = './images/';
// Create a data table with nodes.
nodes.push({id: 5, label: '0x5', image:DIR+'switch.jpg', shape: 'image'});
nodes.push({id: 1, label: '0x1', image:DIR+'switch.jpg', shape: 'image'});
nodes.push({id: 2, label: '0x2', image:DIR+'switch.jpg', shape: 'image'});
nodes.push({id: 4, label: '0x4', image:DIR+'switch.jpg', shape: 'image'});
nodes.push({id: 3, label: '0x3', image:DIR+'switch.jpg', shape: 'image'});
nodes.push({id: 6, label: '0x6', image:DIR+'switch.jpg', shape: 'image'});
edges.push({from: 5, to: 3});
edges.push({from: 1, to: 4});
edges.push({from: 5, to: 6});
edges.push({from: 2, to: 1});
edges.push({from: 3, to: 2});
edges.push({from: 5, to: 4});
edges.push({from: 5, to: 1});
nodes.push({id: 18764998447377, label: '11:11:11:11:11:11', image:DIR+'host.png', shape: 'image'});
edges.push({from: 18764998447377, to: 1});
nodes.push({id: 75059993789508, label: '44:44:44:44:44:44', image:DIR+'host.png', shape: 'image'});
edges.push({from: 75059993789508, to: 6});
```

また，パスの出力は[/lib/algolism](./lib/path.rb) で行った．パケットを送る際に最短経路を探索がなされる．その際にこのファイル内のメソッドが呼び出される．そのメソッド内でそのパスの出力とアルゴリズムのそれぞれのステップでの探索したノードの表示を行う．出力するファイルは[/output/path.js](./output/path.js)である．以下にその例を示す．

```
paths = [];
paths.push([]);
paths[0].push({label:'0', from:18764998447377,  to: 1 });
paths.push([]);
paths[1].push({label:'0', from:18764998447377,  to: 1 });
paths[1].push({label:'1', from:1,  to: 5 });
paths.push([]);
paths[2].push({label:'0', from:18764998447377,  to: 1 });
paths[2].push({label:'1', from:1,  to: 5 });
paths[2].push({label:'2', from:5,  to: 6 });
paths.push([]);
paths[3].push({label:'0', from:18764998447377,  to: 1 });
paths[3].push({label:'1', from:1,  to: 5 });
paths[3].push({label:'2', from:5,  to: 6 });
paths[3].push({label:'3', from:6,  to: 75059993789508 });
```

## Javascript内での動作
今回ブラウザでの表示では，トポロジ情報または最短経路情報が更新された場合に自動で表示も更新されるようにする．javascript内の関数は2つである．メインのコードは[/output/index.html](./output/index.html)内に書かれている．

### require関数
topology.js，path.jsファイルを読み込み，実行する．以下にその部分を示す．

```
  var req = new XMLHttpRequest();
  req.open("GET", "./topology.js", false);
  req.send("");
  eval(req.responseText);
```
Ajaxというjavascript内でhttp通信を行う方式を用いる．XMLHttpRequestでインスタンスを作り，GET命令でjavascriptファイルを読み込む．読み込んだ文字列をeval関数でjavascriptのコードとして実行する．こうすることで別ファイルに記述されたノードやエッジの情報などを配列に格納する．その後，vis.jsに配列を渡してブラウザ上で可視化する．
その後，後述するgetUpdate関数を呼び出す．

### getUpdate関数
この関数ではファイルが更新されているか否かを判定する．Ajaxで各ファイルを読み込み，ヘッダーのlast-modifiedの情報を取得する．この情報はファイルの最終更新日時を表す．取得したlast-modifiedが前回読み込んだ日時から更新されていたらrequire関数を呼び出す．更新されていなかったら```  setTimeout("getUpdate()",1000);```でタイマーをセットし，1秒後にgetUpdate関数を呼び出し，1秒毎にファイルの更新確認を行っている．








