(function ( $ ) {

    L.Icon.Default.imagePath = '/extension/ocmap/design/standard/images';

    L.Circle.include({
        toGeoJSON: function () {
            var feature = {
                feature:{
                    type: 'Feature',
                    properties: {
                        radius: this.getRadius(),
                        type: 'Circle'
                    },
                    geometry: {}
                }
            };
            return L.GeoJSON.getFeature(feature, {
                type: 'Point',
                coordinates: L.GeoJSON.latLngToCoords(this.getLatLng()),
                properties: {radius: this.getRadius()}
            });
        }
    });

    L.CircleMarker.include({
        toGeoJSON: function () {
            var feature = {
                feature:{
                    type: 'Feature',
                    properties: {
                        radius: this.getRadius(),
                        type: 'CircleMarker'
                    },
                    geometry: {}
                }
            };
            return L.GeoJSON.getFeature(feature, {
                type: 'Point',
                coordinates: L.GeoJSON.latLngToCoords(this.getLatLng()),
                properties: {radius: this.getRadius()}
            });
        }
    });

    var addGeoJSONLayer = function (json, map, featureGroup, type, color) {
        var geoJSONLayer = L.geoJson(json, {
            pointToLayer: function(feature, latlng) {
                var geometry = feature.type === 'Feature' ? feature.geometry : feature;
                if (geometry.type === 'Point') {
                    if (feature.properties.radius) {
                        if (feature.properties.type === 'CircleMarker')
                            return new L.CircleMarker(latlng, feature.properties.radius);
                        if (feature.properties.type === 'Circle')
                            return new L.Circle(latlng, feature.properties.radius);
                    } else {
                        var customIcon = L.MakiMarkers.icon({icon: "circle", color: color});
                        return new L.Marker(latlng,  {icon: customIcon});
                    }
                }
            },
            onEachFeature: function(feature, layer) {
                if (feature.properties.name){
                    layer.bindPopup(feature.properties.name);
                }
            }
        });
        geoJSONLayer.eachLayer(function(l){            
            l.options.color = color;
            featureGroup.addLayer(l);
        });
        if (featureGroup.getLayers().length > 0) {
            map.fitBounds(featureGroup.getBounds());
        }
    };

    var loadSource = function(url, type, cb, context){
        switch(type) {
            case 'osm':
                $.ajax({
                    url: url,
                    dataType: "xml",
                    success: function (xml) {
                        var layer = new L.OSMData.DataLayer(xml);
                        var geoJSON = layer.toGeoJSON();
                        if ($.isFunction(cb)) {
                            cb.call(context, geoJSON);
                            return true;
                        }                        
                    }
                });
            break;

            case 'ocql_geo':
                $.ajax({
                    url: url,
                    dataType: "json",
                    success: function (geoJSON) {                            
                        if ($.isFunction(cb)) {
                            cb.call(context, geoJSON);
                            return true;
                        }                        
                    }
                });
            break;
        }
    };

    var loadMap = function($container){
        var osmUrl = 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            osmAttrib = '&copy; <a href="http://openstreetmap.org/copyright">OpenStreetMap</a> contributors',
            osm = L.tileLayer(osmUrl, { maxZoom: 18, attribution: osmAttrib });
            
        var map = new L.Map($container[0], { center: new L.LatLng(0, 0), zoom: 13 });
        map.scrollWheelZoom.disable();
        osm.addTo(map);

        return map;
    };
 
    $.fn.ocviewmap = function() {
        var $element = $(this);    
        var geoJSON = $element.data('geojson');
        var type = $element.data('type');
        var color = $element.data('color');
        var map = loadMap($element); 
        var drawnItems = L.featureGroup().addTo(map);
        addGeoJSONLayer(geoJSON, map, drawnItems, type, color);        
    };

    $.fn.oceditmap = function() {
        var $element = $(this);    

        var mapContainer = $element.find('.map');
        var mapDataContainer = $element.find('.map-data');
        var mapType = $element.find('.map-import-type');
        var mapColor = $element.find('.map-color');  
        var mapUrlInput = $element.find('.map-import-url');
        var mapUrlSubmit = $element.find('.map-import-submit');
    
        var map = loadMap(mapContainer);        
        
        var drawnItems = L.featureGroup().addTo(map);
        map.addControl(new L.Control.Draw({
            edit: {
                featureGroup: drawnItems,
                poly: {
                    allowIntersection: false
                }
            },
            draw: {
                polygon: {
                    allowIntersection: false,
                    showArea: true
                }
            }
        }));
        map.on(L.Draw.Event.CREATED, function (event) {
            var layer = event.layer;
            layer.options.color = mapColor.val();
            drawnItems.addLayer(layer);
            storeData();
        });
        map.on(L.Draw.Event.DELETED, function (event) {
            var data = drawnItems.toGeoJSON();
            if (drawnItems.getLayers().length == 0){
                mapUrlSubmit.show();
            }
            storeData();
        });
        
        L.Control.geocoder({
            collapsed: false,
            placeholder: 'Cerca...',
            errorMessage: 'Nessun risultato.',
            suggestMinLength: 5,
            defaultMarkGeocode: false
        }).on('markgeocode', function (e) {
            map.fitBounds(e.geocode.bbox);
        }).addTo(map);

        mapUrlSubmit.on('click', function (e) {            
            var type = mapType.val();  
            loadSource(mapUrlInput.val(), mapType.val(), function(geoJSON){
                addGeoJSONLayer(geoJSON, map, drawnItems, mapType.val(), mapColor.val());
                storeData();
                mapUrlSubmit.hide();
            });            
            e.preventDefault();
        });

        var storeData = function(){
            var json = drawnItems.toGeoJSON();
            mapDataContainer.val(JSON.stringify(json));
        };        

        var data = mapDataContainer.val();
        if (data.length > 0){
            var json = JSON.parse(data);
            addGeoJSONLayer(json, map, drawnItems, mapType.val(), mapColor.val());
        }
        
        mapColor.spectrum({
            preferredFormat: "hex",
            showInput: true,
            showInitial: true
        });
 
        return this;
    };
 
}( jQuery ));