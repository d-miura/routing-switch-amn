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
##選択したアルゴリズムについて
今回，私達のグループではダイクストラ法の代わりに幅優先探索アルゴリズムを実装した．  
幅優先アルゴリズムにおいて2点間の最短経路が探索される流れを以下に示す．

```
１．空のキューを定義し，スタートノードをキューに追加する．
２．キューの先頭からノードを取り出す．取り出したノードについて以下の処理を行う．
　 ・取り出したノードがゴールノードの場合，その時点で探索を終了する．スタートノードからゴールノードまでの経路を返す．このとき得られる経路は必ず最短経路である．
　 ・上記以外の場合，取り出したノードに接続された全ての子ノードを新たにキュー末尾に追加する．
３．探索が終了するまで２を繰り返す．
```

##実装
今回は， ```bfs.rb``` の ```BreadthFirstSearch``` クラスにおいて，幅優先探索を用いて最短経路を得るアルゴリズムを実装した．以下に主な実装部分である ```run```メソッドと ```search``` メソッドについてソースコードを貼付する．

```
  def run(start, goal)
    start_node = find(start, @all)   #スタートノード
    goal_node = find(goal, @all)   #ゴールノード

    queue = []   #空のキューを定義
    tmp = []

    tmp << start_node.name
    queue << tmp   #キューの先頭にスタートノードを追加

    ans = search(queue, goal_node, 1)   #search関数の返り値からキューを得る
    return ans.last   #キューの末尾の要素に最短経路が格納されているため取り出す
  end
```

```
  def search(queue, goal, i)   #i:何ホップ目まで探索したかを記録するための変数
    start_node_tmp = queue[0]
    start_node = start_node_tmp[0]   #スタートノードをキューの先頭から取り出す 
    @visited << start_node           #探索済みリストにスタートノードを追加

    list = []   #子ノードを格納するためのリストを定義

    while queue[0].length == i do
      current_node_name_tmp = queue.shift   #キューの先頭からノードを取り出す
      current_node_name = current_node_name_tmp[i-1]
      current_node = find(current_node_name, @all)
      current_node.neighbors.each do |adjacent_node|   #取り出したノードの子ノードを全て探索
        neighbor = adjacent_node   #子ノード
        next if @visited.include?(neighbor)   #既に探索済みのノードならば探索しない
        list.append(neighbor)   #リストに子ノードを追加
        @visited << neighbor   #探索済みリストに追加
      end

      #全ての子ノードに対してループ
      list.each do |n|
        tmp = Array.new(current_node_name_tmp)
        tmp.append(n)
        queue.append(tmp)   #スタートノードからその子ノードまでの経路をキューに追加
        #ゴールノードに到達するとその時点におけるキューを返す
        if n == goal.name
          return queue
        end
      end
    end
    return search(queue, goal, i+1)   #再帰呼出し
  end
```

実装した点について，ソースコード内のコメントと共に以下に大まかに説明する．  
初めに， ```search``` メソッドは ```run``` メソッド内で呼び出される際に，スタートノードだけが先頭に格納された状態のキュー，ゴールノード，ホップ数記録用変数 ```i``` を引数で受け取る．  
先頭の要素をキューから取り出し，その要素に接続された全ての子ノードについて既に探索済みであるかどうかを調べる．そのうち探索済みでない子ノードについて，探索済みの印を付け，親ノードと共にキューの末尾に追加していく．探索済みであるノードについては何も行わない．この動作をゴールノードが発見されるまで繰り返す．  
ゴールノードが発見されると，その時点におけるキューを返す．このときキューの最後尾の要素には，スタートノードからゴールノードまでの最短経路が格納されているので，最終的にその値を取り出し ```Creating path:``` として最短経路を出力する．  
  
一方で， ```graph.rb``` において， 既に実装されていた ```dijkstra``` メソッドを参考に ```bfs```メソッドを定義した．また， ```path_manager.rb```の ```maybe_create_shortest_path``` メソッドにおいて， ```dijkstra``` メソッドの代わりに ```bfs```メソッドを呼ぶように変更した．

```
  def bfs(source_mac, destination_mac)
    return if @graph[destination_mac].empty?
    route = BreadthFirstSearch.new(@graph).run(source_mac, destination_mac)
    route.reject { |each| each.is_a? Integer }
  end
```
```
  def maybe_create_shortest_path(packet_in)
    shortest_path = @graph.bfs(packet_in.source_mac,
                                    packet_in.destination_mac)
    return unless shortest_path
    Path.create shortest_path, packet_in
  end
```


##実行結果
今回実装した幅優先探索を用いて，ホスト間でパケットを送受信し ```host1``` から ```host4``` までの最短経路を出力した結果を以下に示す．このとき，既に実装されていたダイクストラ法を用いた場合と同じ結果が出力されたため，正しく実装できていることがわかる．

```
$ ./bin/trema send_packets --source host1 --dest host4
$ ./bin/trema send_packets --source host4 --dest host1
$ ./bin/trema send_packets --source host1 --dest host4
```   

```
Path Manager started.
vis.js mode, output = topology.js
Topology started (vis.js mode, output = topology.js).
Routing Switch started.
Creating path: 11:11:11:11:11:11 -> 0x1:1 -> 0x1:4 -> 0x5:2 -> 0x5:5 -> 0x6:2 -> 0x6:1 -> 44:44:44:44:44:44
Creating path: 44:44:44:44:44:44 -> 0x6:1 -> 0x6:2 -> 0x5:5 -> 0x5:2 -> 0x1:4 -> 0x1:1 -> 11:11:11:11:11:11
```


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

##実行結果
以下に実行した時のアルゴリズムの動作と最短パスを表示する．
[実行結果](https://github.com/handai-trema/routing-switch-amn/blob/master/result.gif)






