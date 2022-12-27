// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import d3 from "d3"
import { Turbo } from "@hotwired/turbo-rails"

import { pie, streamgraph } from "charts"
window.charts = {}
window.charts.pie = pie
window.charts.streamgraph = streamgraph
window.d3 = d3

console.log("application.js loaded")
console.log(d3.version)
