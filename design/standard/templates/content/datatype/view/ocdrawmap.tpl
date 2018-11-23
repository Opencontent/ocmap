{run-once}
{ezcss_require(array(
    'leaflet/leaflet.0.7.2.css'
))}
{ezscript_require(array(
    'leaflet.js',
    'ezjsc::jquery'
))}
{/run-once}

<div id="map-{$attribute.id}" style="width: 100%; height: 600px; margin: 10px 0"></div>

<script>{literal}
    var osm = L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
        { maxZoom: 18, attribution: '&copy; <a href="http://openstreetmap.org/copyright">OpenStreetMap</a> contributors' }),
        map_{/literal}{$attribute.id}{literal} = new L.Map('map-{/literal}{$attribute.id}{literal}', { center: new L.LatLng(0, 0), zoom: 13 }),
        drawnItems_{/literal}{$attribute.id}{literal} = L.featureGroup().addTo(map_{/literal}{$attribute.id}{literal}),
        geojsonLayer_{/literal}{$attribute.id}{literal} = L.geoJson(
            JSON.parse('{/literal}{$attribute.content.geo_json_string}{literal}'),
            {
                pointToLayer: function(feature, latlng) {
                    var geometry = feature.type === 'Feature' ? feature.geometry : feature;
                    if (geometry.type === 'Point') {
                        if (feature.properties.radius) {
                            if (feature.properties.type === 'CircleMarker')
                                return new L.CircleMarker(latlng, feature.properties.radius);
                            if (feature.properties.type === 'Circle')
                                return new L.Circle(latlng, feature.properties.radius);
                        } else {
                            return new L.Marker(latlng);
                        }
                    }
                }
            }
        );
    osm.addTo(map_{/literal}{$attribute.id}{literal});
    map_{/literal}{$attribute.id}{literal}.scrollWheelZoom.disable();
    geojsonLayer_{/literal}{$attribute.id}{literal}.eachLayer(function(l){
        drawnItems_{/literal}{$attribute.id}{literal}.addLayer(l);
    });
    if (drawnItems_{/literal}{$attribute.id}{literal}.getLayers().length > 0) {
        map_{/literal}{$attribute.id}{literal}.fitBounds(drawnItems_{/literal}{$attribute.id}{literal}.getBounds());
    }
{/literal}</script>