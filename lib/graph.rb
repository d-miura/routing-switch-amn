# Run dijkstra on network topology.
class Graph
  # Graph node
  class Node
    attr_reader :name
    attr_reader :neighbors
    attr_accessor :distance
    attr_accessor :prev
    def initialize(name, neighbors)
      @name = name
      @neighbors = neighbors
      @distance = Float::INFINITY
      @prev = nil
      @visited = false
    end

    def maybe_update_distance(from, new_distance)
      return if @distance && new_distance > @distance
      @distance = new_distance
      @prev = from.name
    end

    def visit
      @visited = true
      self
    end

    def unvisited?
      !@visited
    end
  end

  def initialize(data)
    @nodes = data.each_with_object({}) do |(node, neighbors), hash|
      hash[node] = Node.new(node, neighbors)
    end
  end

  def route(start, goal)
    dijkstra start
    tmp = @nodes[goal]
    result = [tmp.name]
    while tmp.prev
      tmp = @nodes[tmp.prev]
      result.unshift tmp.name
    end
    result
  end

  private

  def dijkstra(start_name)
    @nodes[start_name].distance = 0
    loop do
      min_node = find_min_distance_unvisited_node
      break unless min_node
      min_node.neighbors.each do |each|
        @nodes[each].maybe_update_distance(min_node, min_node.distance + 1)
      end
    end
  end

  def find_min_distance_unvisited_node
    found = nil
    @nodes.values.select(&:unvisited?).each do |each|
      found = each.visit if found.nil? || each.distance < found.distance
    end
    found
  end
end
