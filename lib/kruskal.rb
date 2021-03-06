# -*- coding: utf-8 -*-

require_relative 'union_find'

# Finds shortest path.
class Kruskal
  # Graph node
  class Node
    attr_reader :name
    attr_reader :neighbors
    attr_reader :distance
    attr_reader :prev

    def initialize(name, neighbors)
      @name = name
      @neighbors = neighbors
      @distance = rand(100) + 1
      @prev = nil
    end

    def maybe_update_distance_and_prev(min_node)
      new_distance = min_node.distance + 1
      return if new_distance > @distance
      @distance = new_distance
      @prev = min_node
    end
    
    def distance=(new_distance)
      fails if new_distance < 0
      @distance = new_distance
    end

    def <=>(other)
      @distance <=> other.distance
    end
    
    def set_prev(prev)
      @prev = prev
    end
  end

  # Sorted list.
  # TODO: Replace with heap.
  class SortedArray
    def initialize(array)
      @array = []
      array.each { |each| @array << each }
      @array.sort!
    end

    def method_missing(method, *args)
      result = @array.__send__ method, *args
      @array.sort!
      result
    end
  end

  def initialize(graph)
    @all = graph.map { |name, neighbors| Node.new(name, neighbors) }  #All nodes
    @unvisited = SortedArray.new(@all)

    @mst = []
    @undecided_nodes = []
    for node in @all do
      @undecided_nodes.append(node.name)
    end

  end

#（ランダムにノード選ぶ→ランダムに接続ノード選ぶ）←最小木に入れる
#（ランダムにノード選ぶ→ランダムに接続ノード選ぶ）←閉路を成すか？

  def run(start, goal)
    start_node = find(start, @all)              #スタートノードstartを取得する．
    union_find = UnionFind.new(@undecided_nodes)
    @undecided_nodes.delete(start_node.name)    #最短経路を成さないノード集合undecided_nodesからstartを削除する．
    @mst.append(start_node.name)      #最短経路を成すノード集合decided_nodesへstartを追加する．


    #最小全域木を求める．
    while @mst.size <= 6 do              #最小全域木のサイズがノード数より大きくなるまでループ
      neighbors = []                                 #decided_nodesに含む任意のノードと辺を成すdecided_nodesに含まれる任意の点
      #break_switch = false                            #for focused_node_name in @decided_nodes doから抜け出すスイッチ
      i = 0
      
      for focused_node_name in @mst do
        focused_node = find(focused_node_name, @all)  #mstに含む任意のノードfocused_nodeを取得
        focused_node.neighbors.each do |each|         #focused_nodeと辺を成すノードに対してループ．
          neighbors[i] = find(each, @all)                 #focused_nodeと辺を成すノードneighborを取得する
          i = i + 1
        end
        neighbor = neighbors.sample   #近接ノードからランダムに１つノードを取り出す

        #木と木が閉路を作らなかったら
        if !union_find.connected?(focused_node.name, neighbor.name) then
          union_find.union(focused_node.name, neighbor.name)   #木と木を繋げるneighbor.set_prev(focused_node)           #neighborをdecided_nodesへ追加する際のfocused_nodeを記録する
          neighbor.set_prev(focused_node)           #neighborをdecided_nodesへ追加する際のfocused_nodeを記録する
          @mst.append(neighbor.name)
        end
      end

      #@undecided_nodes.delete(neighbor.name)  #neighborをundecided_nodesから削除する．
      #@mst.append(neighbor.name)    #neighborをdecided_nodesへ追加する．
    end

    #ここからはDijkstraクラスと同じ．
    #上で求めた最小全域木からstartからgoalへの最短経路を求める．
    result = path_to(goal)                #記録したneighborをdecided_nodesへ追加する際のfocused_nodeをgoalからstartまで辿り，反転させたものを結果resultとして得る．
    result.include?(start) ? result : []  #resultにstartが含まれていれば，resultは連結グラフ内の系列であるのでresultを返し，そうでなければ空の系列を返す．
  end

  private

  # This method smells of :reek:FeatureEnvy but ignores them
  # This method smells of :reek:DuplicateMethodCall but ignores them
  def path_to(goal)
    [find(goal, @all)].tap do |result|
      result.unshift result.first.prev while result.first.prev
    end.map(&:name)
  end

  def find(name, list)
    found = list.find { |each| each.name == name }
    fail "Node #{name.inspect} not found" unless found
    found
  end
end
