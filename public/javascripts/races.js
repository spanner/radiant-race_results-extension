Array.prototype.sortBy = function(property, reversed) {
  if (typeof this[0][property] == "number") {
    this.sort(function (a,b) {
      if (reversed) {
        return b[property] - a[property];
      } else {
        return a[property] - b[property];
      }
    });
  } else {
    this.sort(function (a,b) { 
      if (reversed) {
        return b[property].localeCompare(a[property]);
      } else {
        return a[property].localeCompare(b[property]);
      } 
    });
  }
};

String.prototype.toSeconds = function() {
  var timeArray = this.split(":");
  var seconds = 0;
  seconds += (parseInt(timeArray[0], 10) * 3600);
  seconds += (parseInt(timeArray[1], 10) * 60);
  seconds += (parseInt(timeArray[2], 10));
  return seconds;
};

(function($) { 

  var timeFormat = function(value, axis) {
    if (value == 0) return '0';
    var h = Math.floor(value/3600);
    var m = Math.floor((value % 3600)/60);
    if ( m < 10) m = "0" + m;
    var s = value % 60;
    if ( s < 10) s = "0" + s;
    var tc = [h,m].join(":");
    if (s != "00") tc = tc + ":" + s;
    return tc;
  };
  
  function ResultsRow(tr) {
		var self = this;
		$.extend(self, {
			element: $(tr),
			pos: null,
			club: null,
			cat: null,
			name: null,
			time: null
		});
		this.club = this.element.find('td.club').text();
		if (this.club == "") this.club = "UA";
		this.pos = parseInt(this.element.find('td.pos').text(), 10);
		this.name = this.element.find('td.name').text();
		this.cat = this.element.find('td.cat').text();
		this.prizes = this.element.find('td.prizes').text();
		this.time = this.element.find('td.time').text().toSeconds();
	};
	
	function ResultsColumn(th, table) {
	  var self = this;
		$.extend(self, {
		  element: $(th),
		  link: $(th).find('a'),
		  table: table,
		  sortProperty: $(th).attr('class'),
		  toggle: function (event) {
		    event.preventDefault();
        if (self.element.hasClass('up')) {
          self.table.sort(self.sortProperty, true);
          self.link.removeClass('up');
					self.link.addClass('down');
        }
 				else if (self.element.hasClass('down')) {
					self.table.sort(self.sortProperty);
					self.link.removeClass('down');
					self.link.addClass('up');
				}
				else {
          self.table.sort(self.sortProperty);          
          self.link.addClass('up');
        }
		  },
		  reset: function () {
        self.link.removeClass('up');
				self.link.removeClass('down');
		  }
		});
		self.link.addClass('sortable');
		if (self.sortProperty == 'pos') self.link.addClass('up');
		self.link.click(self.toggle);
  };
  
	function ResultsTable(table) {
		var self = this;
		var tbody = $(table).find('tbody');
		$.extend(self, {
			element: $(table),
			wrapper: tbody,
			finishers: [],
			dnfs: [],
			columns: [],
			sort: function (property, reversed) {
				self.reset();
				self.finishers.sortBy(property, reversed);
				self.refresh();
			},
      reset: function (argument) {
        self.finishers.sortBy('pos');
        $.each(self.columns, function () { this.reset(); });
      },
			refresh: function () {
				$.each(self.finishers.concat(self.dnfs), function (i, row) {
					self.wrapper.append(row.element);
				});
			}
		});
		self.element.find('tr.finisher').each(function () {
			self.finishers.push(new ResultsRow(this));
		});
		self.element.find('tr.unfinished').each(function () {
			self.dnfs.push(new ResultsRow(this));
		});
		self.element.find('th').each(function () {
			self.columns.push(new ResultsColumn(this, self));
		});
	};

	$.fn.sortable_results = function () {
		this.each(function () {
			new ResultsTable(this);
		});
	};
	
	$.fn.build_chart = function () {
		this.each(function () {
      var self = $(this);
      var waiter = self.find('a.waiting');
      var href = waiter.attr('href');
      var list = self.find('ul.labels').eq(0);
      var ticks = [];
      list.find('li').each(function (i, el) { ticks.push([i+1, $(el).text()]); });
      list.hide();
      var plot_options = {
        series: {
          lines: { 
            show: true
          },
          shadowSize: 2,
          points: {show: true}
        },
        xaxis: {
          show: true, 
          ticks: ticks
        }, 
        yaxis: {
          show: true,
          tickSize: 1800,
          tickFormatter: timeFormat
        },
        grid: {
          show: true,
          borderWidth: 0,
          hoverable: true, 
          clickable: true 
        },
        legend: {
          show: false
        }
      };

      self.qtip({
         prerender: true,
         content: 'Loading...',   // Use a loading message primarily
         position: {
            viewport: $(window),  // Keep it visible within the window if possible
            target: 'mouse',      // Position it in relation to the mouse
            adjust: { x: 7 }      // ...but adjust it a bit so it doesn't overlap it.
         },
         show: false,             // We'll show it programatically, so no show event is needed
         style: {
            classes: 'ui-tooltip-shadow ui-tooltip-tipped',
            tip: false            // Remove the default tip.
         }
      });

      $.getJSON(href, function (data) {
        var length = data[0].length;
        var series = [];
        $.each(data, function () {
          var coordinates = [[0,0]];
          var i = 1;
          $.each(this['splits'], function () {
            coordinates.push([i++, this]);
          });
          series.push({
            data: coordinates,
            label: this['name']
          });
        });

        self.empty();
        
        var plot = $.plot($(self), series, plot_options);

        $(self).bind("plothover", function (event, pos, item) {
          var qtip = self.qtip();
          if(!item) {
            qtip.cache.point = false;
            qtip.cache.series = false;
            return qtip.hide(event);
          }
          var previousPoint = qtip.cache.point;
          if (qtip.cache.point != item.dataIndex + item.series.label) {
            console.log("plothover", item);
            qtip.cache.point = item.dataIndex + item.series.label;
            qtip.elements.tooltip.stop(1, 1);
            var content = item.series.label + ": " + timeFormat(item.datapoint[1]);
            qtip.set('content.text', content);
            qtip.show(pos);
          }
        });

        $(self).bind("plotclick", function (event, pos, item) {
          if(item) {
            self.redrawAround(item.series);
          }
        });
      });
		});
	};
	
	$.fn.rebuild_chart = function (selector) {
		this.each(function () {
      var self = $(this);
      self.submit(function (e) {
        $(selector).build_chart(self.attr('action') + '?' + self.serialize());
        return false;
      });
    });
  };
  
})(jQuery);


function showTooltip(x, y, contents) {
    $('<div id="tip" class="tooltip">' + contents + '</div>').css( {
        display: 'block',
        top: y + 5,
        left: x + 5
    }).appendTo("body").fadeIn(200);
}

