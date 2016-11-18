var nodes = null;
var edges = null;
var network = null;
nodes = [];
// Create a data table with links.
edges = [];
var DIR = './images/';
// Create a data table with nodes.

nodes.push({id: 3, label: '0x3', image:DIR+'switch.jpg', shape: 'image'});

nodes.push({id: 6, label: '0x6', image:DIR+'switch.jpg', shape: 'image'});

nodes.push({id: 2, label: '0x2', image:DIR+'switch.jpg', shape: 'image'});

nodes.push({id: 5, label: '0x5', image:DIR+'switch.jpg', shape: 'image'});

nodes.push({id: 4, label: '0x4', image:DIR+'switch.jpg', shape: 'image'});

nodes.push({id: 1, label: '0x1', image:DIR+'switch.jpg', shape: 'image'});

edges.push({from: 3, to: 2});

edges.push({from: 3, to: 5});

edges.push({from: 5, to: 6});

edges.push({from: 5, to: 4});

edges.push({from: 2, to: 1});

edges.push({from: 1, to: 4});

edges.push({from: 5, to: 1});

nodes.push({id: 3232235521, label: '192.168.0.1', image:DIR+'host.png', shape: 'image'});

edges.push({from: 3232235521, to: 1});

nodes.push({id: 3232235524, label: '192.168.0.4', image:DIR+'host.png', shape: 'image'});

edges.push({from: 3232235524, to: 6});

