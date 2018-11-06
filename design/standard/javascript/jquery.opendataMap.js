(function ($) {

  const opendataMap = {
    tools: null,
    mapId: '',
    markersId: '',
    markers: null,
    map: null,
    parameters: [],

    buildFilterInput: function(facets, facet) {
      for (var i = 0, len = facets.length; i < len; i++) {
        var currentFilters = this.tools.settings.builder.filters;
        var facetDefinition = facets[i];

        if (facetDefinition.field === facet.name && !facetDefinition.hidden) {

          var select = $('<select id="' + facetDefinition.field + '" data-field="' + facetDefinition.field + '" data-placeholder="Seleziona" name="' + facetDefinition.field + '">');

          if (facetDefinition.multiple) {
            select.attr('multiple', 'multiple');
          } else {
            select.append($('<option value=""></option>'));
          }

          facetDefinition.data = facet.data;

          $.each(facetDefinition.data, function (value, count) {
            if (value.length > 0) {
              var quotedValue = encodeURIComponent('"' + value + '"');
              var option = $('<option value="' + quotedValue + '" data-value="'+value+'">' + value.replace(/_/g, ' ') + ' (' + count + ')</option>');
              if (currentFilters[facetDefinition.field]
                && currentFilters[facetDefinition.field].value
                && $.inArray(quotedValue, currentFilters[facetDefinition.field].value) > -1) {
                option.attr('selected', 'selected');
              }
              select.append(option);
            }
          });

          var selectContainer = $('<div class="form-group" style="margin-bottom: 10px; float: left; margin-left: 10px"></div>');
          var label = $('<label for="' + facetDefinition.field + '">' + facetDefinition.name + '</label>');

          selectContainer.append(label);
          selectContainer.append(select);
          this.attachFilterInput(select, this.tools);
          return selectContainer;
        }
      }
    },

    attachFilterInput: function ($select) {
      $select.chosen({width: '100%', allow_single_deselect: true}).on('change', function (e) {
        var that = $(e.currentTarget);
        var values = $(e.currentTarget).val();
        if (typeof $(e.currentTarget).attr('multiple') == 'undefined' && values) {
          values = [values]
        }
        if (values != null && values.length > 0) {
          opendataMap.tools.settings.builder.filters[that.data('field')] = {
            'field': that.data('field'),
            'operator': 'contains',
            'value': values
          };
        } else {
          opendataMap.tools.settings.builder.filters[that.data('field')] = null;
          console.log('elimina filtro');
        }
        console.log(opendataMap.tools.settings.builder.filters);
        opendataMap.loadMarkersInMap();

      });
    },

    buildQuery: function (notEncoded) {
      var query = '';
      $.each(opendataMap.tools.settings.builder.filters, function () {
        if (this != null) {
          if ($.isArray(this.value)) {
            query += this.field + " " + this.operator + " ['" + this.value.join("','") + "']";
            query += ' and ';
          }
        }
      });
      if (opendataMap.tools.settings.builder.query != null) {
        query += this.tools.settings.builder.query;
      }
      console.log(' -- Query: ' + query);
      return !notEncoded ? encodeURIComponent(query) : query;
    },

    loadMap: function () {
      var tiles = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
        maxZoom: 18,
        attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
      });
      opendataMap.map = L.map(opendataMap.mapId).addLayer(tiles);
      opendataMap.map.scrollWheelZoom.disable();
      opendataMap.markers = L.markerClusterGroup();
      opendataMap.loadMarkersInMap();
    },

    loadMarkersInMap:  function(){
      var endpoint = opendataMap.tools.settings.endpoint;
      var query = opendataMap.buildQuery(true);
      var parameters = "";
      $.each( opendataMap.parameters, function (i, v) {
        parameters = parameters + '&' + v.key + '=' + v.value;
      });
      var geoJson = endpoint + '?query=' + query + parameters;

      if (opendataMap.map) {
        opendataMap.markers.clearLayers();
        lastMapQuery = query;
        var markerMap = {};
        $.getJSON(geoJson, function (data) {

          var geoJsonLayer = L.geoJson(data.content, {
            pointToLayer: function (feature, latlng) {
              var customIcon = L.MakiMarkers.icon({icon: "star", color: "#f00", size: "l"});
              var marker = L.marker(latlng, {icon: customIcon});

              markerMap[feature.id] = marker;
              return marker;
            }
          });
          opendataMap.markers.addLayer(geoJsonLayer);
          opendataMap.map.addLayer(opendataMap.markers);
          opendataMap.map.fitBounds(opendataMap.markers.getBounds());

          console.log(opendataMap.markers.getBounds());

          $('.content-filters').find('.form').remove();
          var form = $('<form class="form">');
          $.each(data.facets, function () {
            form.append( opendataMap.buildFilterInput(facets, this) );
          });
          $('.content-filters').append(form).show();


        });
        opendataMap.markers.on('click', function (a) {
          $.getJSON( endpoint + "?contentType=marker&view=panel&id=" + a.layer.feature.id, function (data) {
            var popup = new L.Popup({maxHeight: 360});
            popup.setLatLng(a.layer.getLatLng());
            popup.setContent(data.content);
            opendataMap.map.openPopup(popup);
          });
        });
      }
    }







  }

  $.opendataMap = opendataMap;

}(jQuery));
