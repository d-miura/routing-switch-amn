# -*- coding: utf-8 -*-
class BreadthFirstSearch
  class Node
    attr_reader :name
    attr_reader :neighbors
    attr_accessor :distance
    attr_reader :prev

    def initialize(name, neighbors)
      @name = name
      @neighbors = neighbors
      @distance = 100_000
      @prev = nil
    end

    def maybe_update_distance_and_prev(min_node)
      new_distance = min_node.distance + 1
      return if new_distance > @distance
      @distance = new_distance
      @prev = min_node
    end

    def <=>(other)
      @distance <=> other.distance
    end
  end

  class SortedArray
    def initialize(array)
      @array = []
      array.each { |each| @array << each }
      @array.sort!   #@arrayを昇順にソート
    end

    def method_missing(method, *args)
      result = @array.__send__ method, *args
      @array.sort!
      result
    end
  end

  def initialize(graph)
    @graph = graph
    @visited = []
    @edge_to = {}

    @all = graph.map { |name, neighbors| Node.new(name, neighbors) }   #name, neighborsを初期化したものを配列で返す
    @unvisited = SortedArray.new(@all)
    @undecided_nodes = []
    for node in @all do
      @undecided_nodes.append(node.name)
    end
  end

  def shortest_path_to(start, node)
    return unless has_path_to?(node)
    path = []

    while(node != start) do
      path.unshift(node) # unshift adds the node to the beginning of the array
      node = @edge_to[node]
    end

    path.unshift(start)
  end

  def run(start, goal)
    start_node = find(start, @all)
    goal_node = find(goal, @all)

    queue = []
    tmp = []

    tmp << start_node.name
    queue << tmp

    ans = search(queue, goal_node, 1)
    puts "ans = #{ans.last}"
    path = ans.last

    puts path

    return ans.last

    #result = path_to(goal)
    #result.include?(start) ? result : []
  end

  private

  # If we visited the node, so there is a path
  # from our source node to it.
  def has_path_to?(node)
    @visited.include?(node)
  end

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

  def search(queue, goal, i)
    start_node_tmp = queue[0]
    start_node = start_node_tmp[0]
    @visited << start_node

    list = []

    #puts "length = #{first_element_length}"
    while queue[0].length == i do
      current_node_name_tmp = queue.shift   #current_node_name = [start]
      current_node_name = current_node_name_tmp[i-1]
      current_node = find(current_node_name, @all)
      #current_node = current_node_name
      #puts "current_node = #{current_node.name}"
      current_node.neighbors.each do |adjacent_node|
        #neighbor = find(adjacent_node, @all)
        neighbor = adjacent_node
        #puts "neighbor = #{neighbor.name}"
        next if @visited.include?(neighbor)
        list.append(neighbor)
        @visited << neighbor
      end
      puts "list = #{list}"
      puts goal

      list.each do |n|
        tmp = Array.new(current_node_name_tmp)   #tmp = [current_node]
        tmp.append(n)   #tmp = [current_node, neighbor]
        queue.append(tmp)
        if n == goal.name
          return queue
        end
      end
    end
    return search(queue, goal, i+1)
  end
end
