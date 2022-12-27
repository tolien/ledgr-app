import d3 from 'd3';

console.log("charts/index.js loaded")
window.d3 = d3;

export {default as pie} from 'charts/pie'
export {default as streamgraph} from 'charts/streamgraph'
