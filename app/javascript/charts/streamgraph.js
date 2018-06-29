import * as d3 from 'd3';

var streamgraph = function() {
var width = 450,
    height = 250;

function stackMax(layer) {
	return d3.max(layer, function(d) {
		return d[1];
	});
}

function stackMin(layer) {
	return d3.min(layer, function(d) {
		return d[0];
	});
}

// group data by item ID
var itemNest = d3.nest()
	.key(function(d) {
		return d.item_id;
	});

// group data by date
var dateNest = d3.nest()
	.key(function(d) {
		return d.date;
	});

var stack = d3.stack()
//.offset(d3.stackOffsetWiggle)
.order(d3.stackOrderAscending)
.value(function(d, key) { var nestedByItem = itemNest.map(d);
if (nestedByItem.has(key) && nestedByItem.get(key).length > 0) { return nestedByItem.get(key)[0].value; } else { return 0; }});
var margin = {top: 0, right: 0, bottom: 0, left: 0};

var x = d3.scaleTime()
	.range([0, width - margin.left - margin.right]);	
var y = d3.scaleLinear()
	.range([height - margin.top - margin.bottom, 0]);
var zColours = Array.from(d3.schemeBlues[9]).reverse();
	
	var area = d3.area()
		.x(function(d, i) {
			return x(d.data[0].date);
		})
		.y0(function(d) {
			return y(d[0]);
		})
		.y1(function(d) {
			return y(d[1]);
		});

    width = width - margin.left - margin.right,
    height = height - margin.top - margin.bottom;
    	
var z;

var chart = function(selection) {
var svg = selection.append("svg")
	.attr("width", width)
	.attr("height", height);

  var data = selection.data()[0];

	var g = svg.append("g")
	    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

var xAxis = g.append("g")
        .attr("class", "axis axis--x")
        .attr("transform", "translate(0," + (height) + ")")
		
var yAxis = g.append("g")
        .attr("class", "axis axis--y")

    var topItems;
    if (data['top_items']) {
        topItems = data['top_items'];
        var interpolatedColours = d3.quantize(d3.interpolateHcl(zColours[0], zColours[zColours.length - 1]), topItems.length + 1);
        console.log(interpolatedColours);
        z = d3.scaleOrdinal(interpolatedColours);
        for (var item = 0; item < topItems.length; item++) {
            z(topItems[item].id);
        }
    }
    else {
        z = d3.scaleOrdinal(d3.quantize(d3.interpolateHcl(zColours[0], zColours[zColours.length - 1]), 10));
    }

    if (data['data']) {
        data = data['data'];
    }
	data.map(
		function(d, i) { d.date = new Date(d.date); }); 
	
	x.domain(d3.extent(data, function(d) { return d.date}));
	
	stack.keys(itemNest.map(data).keys())
	var stackeddata = dateNest.entries(data).map(function(d, i) { return d.values })
	var layers = stack(stackeddata);
	y.domain([0, d3.max(layers, stackMax)])

	g.selectAll('path').remove();	

var path = g.selectAll("path")
		.data(layers)
		.attr("d", area)
		.enter().append("path")
		.attr("d", area)
		.attr("class", function(d, i) {
		    return "item" + d.key;
		})
		.attr("fill", function(d, i) {
        // if the item is not in topItems (and topItems is defined)
        // use the same colour for all 'other' items
		if (topItems) {
    		for (var i = 0; i < topItems.length; i++) {
	    	    if (topItems[i].id == d.key) {
		            return z(d.key);
		        }
    		}
    		return z("Other");
        }
        else {
            return z(d.key);
        }
		})
		.exit().remove();
		
        xAxis.call(d3.axisBottom(x));
        yAxis.call(d3.axisLeft(y).ticks(10));
		

}

return chart;
}
export default function (selector, data) {
    if (selector && data) {
        var chart_holder = d3.select(selector);
        d3.json(data).then(function(data) {
              chart_holder.datum(data);
              var drawer = streamgraph();
              chart_holder.call(drawer)
        });
    }
}
