var piechart = function() {
var width = 250,
    height = 250,
    radius = Math.min(width, height) / 2;

  var color = d3.scaleOrdinal(d3.schemePastel1);
  
var arc = d3.arc()
    .outerRadius(radius - 10)
    .innerRadius(0);

var labelArc = d3.arc()
    .outerRadius(radius - 40)
    .innerRadius(radius - 40);

var pie = d3.pie()
    .value(function(d) { return d.sum; })
    
function chart(selection) {
var svg = selection.append("svg")
    .attr("width", width)
    .attr("height", height)
  .append("g")
    .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");
  
  var data = selection.data()[0];
  svg.datum(data);
  
  var g = svg.selectAll(".arc").data(pie(data));
           
    var gEnter = g.enter().append("g")
      .attr("class", "arc");
      gEnter.append('path');
      gEnter.append('text');

      
      g.exit().remove();
      
      svg.selectAll('.arc').select('path').attr("d", arc)
      .style("fill", function(d) { return color(d.data.name); });

    svg.selectAll('.arc').select('text')
      .attr("transform", function(d) { return "translate(" + labelArc.centroid(d) + ")"; })
      .attr("dy", ".35em")
      .text(function(d) { 
        var arcSize = d.endAngle - d.startAngle;
        arcSize = arcSize * (180 / Math.PI);
      });

}
return chart;
}

function draw_pie(selector, data) {
    if (selector && data) {
        var chart_holder = d3.select(selector);
        d3.json(data, function(error, data) {
            if (error) { console.log(error); }
              chart_holder.datum(data)
                drawer = piechart();
              chart_holder.call(drawer)

        });
    }
}

