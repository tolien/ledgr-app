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
//    .startAngle(function() { return Math.PI / 2; })
//    .endAngle(function() { return (2 * Math.PI + Math.PI / 2) });
    
function chart(selection) {
var svg = selection.append("svg")
    .attr("width", width)
    .attr("height", height)
  .append("g")
    .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");
  
  /*if (svg.data() && svg.data()[0]) {
    var old = svg.data()[0];
    old.forEach(function(oldD, oldI) {
      var found = false;
      data.forEach(function(newD, newI) {
        if (oldD.name == newD.name) {
          found = true;
          if (oldD.sum != newD.sum) {
            console.log("Value changed for " + newD.name + " from " + oldD.sum + " to " + newD.sum);
            return;
          }
        }
      })
      if (!found) { console.log (oldD.name + " is no more.") };
    });
  }*/
  
  var data = selection.data()[0];
  svg.datum(data);
  
  var g = svg.selectAll(".arc").data(pie(data));
// console.log("End angle from data: " + 180 * pie(data)[0].endAngle / Math.PI);      
           
    var gEnter = g.enter().append("g")
      .attr("class", "arc");
      gEnter.append('path');
      gEnter.append('text');

// console.log("End angle from data bound to .arc: " + 180 * svg.selectAll('.arc').data()[0].endAngle / Math.PI);      
      
      g.exit().remove();
      
      svg.selectAll('.arc').select('path').attr("d", arc)
      .style("fill", function(d) { return color(d.data.name); });

//  g.enter().selectAll('.arc').append("text");
//    console.log(svg.selectAll('.arc').data()[0].data);
    svg.selectAll('.arc').select('text')
      .attr("transform", function(d) { return "translate(" + labelArc.centroid(d) + ")"; })
      .attr("dy", ".35em")
      .text(function(d) { 
        var arcSize = d.endAngle - d.startAngle;
        arcSize = arcSize * (180 / Math.PI);
//        console.log(d.data.name, arcSize);
        if (Math.ceil(arcSize) >= 20) {
    //        return d.data.name;
        }
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

