// Generated by CoffeeScript 1.11.1
(function() {
  var d3, db, levelup, levelws;

  levelup = require('levelup');

  levelws = require('level-ws');

  db = levelws(levelup("db"));

  d3 = require('d3');

  module.exports = {

    /*
      `get(callback)` 
      ——————— 
      returns some hard-coded metrics 
    
      `callback`: callback function
     */
    get: function(callback) {
      return callback(null, [
        {
          timestamp: (new Date('2013-11-04 14:00 UTC')).getTime(),
          value: 12
        }, {
          timestamp: (new Date('2013-11-04 14:30 UTC')).getTime(),
          value: 15
        }
      ]);
    },
    put: function(id, metrics, callback) {
      var i, len, metric, results, timestamp, value;
      results = [];
      for (i = 0, len = metrics.length; i < len; i++) {
        metric = metrics[i];
        timestamp = metric.timestamp, value = metric.value;
        results.push(db.put('t', value, function() {
          db.get('t', function(err, data) {
            console.log(JSON.stringify(data));
          });
        }));
      }
      return results;
    },
    save: function(id, metrics, callback) {
      var i, len, metric, results;
      console.log("heyy");
      results = [];
      for (i = 0, len = metrics.length; i < len; i++) {
        metric = metrics[i];
        results.push(console.log("coucou"));
      }
      return results;
    },
    InitChart: function() {
      var HEIGHT, MARGINS, WIDTH, barData, vis, xAxis, xRange, yAxis, yRange;
      barData = [
        {
          'x': 1,
          'y': 5
        }, {
          'x': 20,
          'y': 20
        }, {
          'x': 40,
          'y': 10
        }, {
          'x': 60,
          'y': 40
        }, {
          'x': 80,
          'y': 5
        }, {
          'x': 100,
          'y': 60
        }, {
          'x': 120,
          'y': 60
        }
      ];
      vis = d3.select('#visualisation');
      WIDTH = 1000;
      HEIGHT = 500;
      MARGINS = {
        top: 20,
        right: 20,
        bottom: 20,
        left: 50
      };
      xRange = d3.scale.ordinal().rangeRoundBands([MARGINS.left, WIDTH - MARGINS.right], 0.1).domain(barData.map(function(d) {
        return d.x;
      }));
      yRange = d3.scale.linear().range([HEIGHT - MARGINS.top, MARGINS.bottom]).domain([
        0, d3.max(barData, function(d) {
          return d.y;
        })
      ]);
      xAxis = d3.svg.axis().scale(xRange).tickSize(5).tickSubdivide(true);
      yAxis = d3.svg.axis().scale(yRange).tickSize(5).orient('left').tickSubdivide(true);
      vis.append('svg:g').attr('class', 'x axis').attr('transform', 'translate(0,' + HEIGHT - MARGINS.bottom + ')').call(xAxis);
      vis.append('svg:g').attr('class', 'y axis').attr('transform', 'translate(' + MARGINS.left + ',0)').call(yAxis);
      vis.selectAll('rect').data(barData).enter().append('rect').attr('x', function(d) {
        return xRange(d.x);
      }).attr('y', function(d) {
        return yRange(d.y);
      }).attr('width', xRange.rangeBand()).attr('height', function(d) {
        return HEIGHT - MARGINS.bottom - yRange(d.y);
      }).attr('fill', 'grey').on('mouseover', function(d) {
        d3.select(this).attr('fill', 'blue');
      }).on('mouseout', function(d) {
        d3.select(this).attr('fill', 'grey');
      });
    }
  };

}).call(this);