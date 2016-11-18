require 'pio'
require 'erb'

module View
  # Topology controller's GUI (vis.js).
  class Vis
    def initialize(output = 'index.html')
      @output = output
    end

    # rubocop:disable AbcSize
    def update(_event, _changed, topology)
      outtext = Array.new
      nodes = topology.switches.each_with_object({}) do |each, tmp|
        outtext.push(sprintf("nodes.push({id: %d, label: '%#x', image:DIR+'switch.jpg', shape: 'image'});", each.to_i, each.to_hex))
      end
      topology.links.each do |each|
        #next unless nodes[each.dpid_a] && nodes[each.dpid_b]
        outtext.push(sprintf("edges.push({from: %d, to: %d});", each.dpid_a.to_i, each.dpid_b.to_i))
      end
      #added (2016.11.9) add ellipse with ip_address and link between host and switch
      topology.hosts.each do |each|  #for all host
        outtext.push(sprintf("nodes.push({id: %d, label: '%s', image:DIR+'host.png', shape: 'image'});", each[1].to_i, each[1].to_s))#add ellipse with ip_address(each[1])
        outtext.push(sprintf("edges.push({from: %d, to: %d});", each[1].to_i, each[2].to_i))#add link between host and switch(each[2]:switch dpid)
      end
      @topology = outtext
      fhtml = open(@output, "w")
      fhtml.write(ERB.new(File.open('lib/view/topology.html').read).result(binding))
    end
    # rubocop:enable AbcSize

    def to_s
      "vis.js mode, output = #{@output}"
    end
  end
end
