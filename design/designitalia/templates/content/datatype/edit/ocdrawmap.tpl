{default attribute_base='ContentObjectAttribute' html_class='full' placeholder=false()}
    <div class="Form-field{if $attribute.has_validation_error} has-error{/if}">
        <label class="Form-label {if $attribute.is_required}is-required{/if}" for="ezcoa-{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}">
            {first_set( $contentclass_attribute.nameList[$content_language], $contentclass_attribute.name )|wash}
            {if $attribute.is_information_collector} <em class="collector">{'information collector'|i18n( 'design/admin/content/edit_attribute' )}</em>{/if}
            {if $attribute.is_required} ({'richiesto'|i18n('design/ocbootstrap/designitalia')}){/if}
        </label>

        {if $contentclass_attribute.description}
            <em class="attribute-description">{first_set( $contentclass_attribute.descriptionList[$content_language], $contentclass_attribute.description)|wash}</em>
        {/if}

{run-once}
{ezcss_require(array(
    'leaflet/leaflet.0.7.2.css',
    'leaflet/geocoder/Control.Geocoder.css',
    'leaflet/Control.Loading.css',
    'leaflet.draw.css'
))}
{ezscript_require(array(
    'leaflet.0.7.2.js',
    'ezjsc::jquery',
    'leaflet/Control.Loading.js',
    'leaflet/geocoder/Control.Geocoder.js',
    'leaflet.draw.js',
    'leaflet-osm-data.js'
))}
{/run-once}

        <div id="map-{$attribute.id}" style="width: 100%; height: 600px; margin: 10px 0"></div>

        <div style="margin: 10px 0">
            <label class="Form-label">
                {'Import from OSM Full XML'|i18n('ocdrawmap/attribute')}
            </label>
            <em class="attribute-description">{'Example: https://www.openstreetmap.org/api/0.6/relation/2220827/full'|i18n('ocdrawmap/attribute')}</em>
            <div class="Grid Grid--withGutter">
                <div class="Grid-cell u-size8of12 u-sm-size8of12 u-md-size8of12 u-lg-size8of12">
                    <input class="Form-input"
                           id="osm-url"
                           name="{$attribute_base}_ocdrawmap_osm_url_{$attribute.id}"
                           value=""
                           type="text"/>
                </div>
                <div class="Grid-cell u-size4of12 u-sm-size4of12 u-md-size4of12 u-lg-size4of12" style="padding-top: 2px">
                    <button class="btn" type="submit" id="import-osm-url"
                            name="CustomActionButton[{$attribute.id}_ocdrawmap_save_osm_url]">
                        {'Import'|i18n( 'design/standard/content/datatype' )}
                    </button>
                </div>
            </div>
        </div>

        <input id="map-data-{$attribute.id}"
               class="map-data"
               type="hidden"
               name="{$attribute_base}_ocdrawmap_data_text_{$attribute.id}"
               value="{$attribute.content.geo_json_string|wash()}" />

        {literal}
        <style>
            .leaflet-div-icon {
                background: #fff !important;
                border: 1px solid #666 !important;
            }
        </style>
        <script>

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
            var mapContainer = 'map-{/literal}{$attribute.id}{literal}';
            var mapDataContainer = 'map-data-{/literal}{$attribute.id}{literal}';

            var osmUrl = 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                osmAttrib = '&copy; <a href="http://openstreetmap.org/copyright">OpenStreetMap</a> contributors',
                osm = L.tileLayer(osmUrl, { maxZoom: 18, attribution: osmAttrib }),
                map = new L.Map(mapContainer, { center: new L.LatLng(0, 0), zoom: 13 }),
                drawnItems = L.featureGroup().addTo(map);
            map.scrollWheelZoom.disable();
            osm.addTo(map);
            L.Control.geocoder({
                collapsed: false,
                placeholder: 'Cerca...',
                errorMessage: 'Nessun risultato.',
                suggestMinLength: 5,
                defaultMarkGeocode: false
            }).on('markgeocode', function (e) {
                map.fitBounds(e.geocode.bbox);
            }).addTo(map);

            $('#import-osm-url').on('click', function (e) {
                $.ajax({
                    url: $('#osm-url').val(),
                    // or "http://www.openstreetmap.org/api/0.6/way/52477381/full"
                    dataType: "xml",
                    success: function (xml) {
                        var layer = new L.OSMData.DataLayer(xml);
                        //layer.addTo(map);
                        //map.fitBounds(layer.getBounds());
                        addGeoJson(layer.toGeoJSON());
                        storeData();
                    }
                });
                e.preventDefault();
            });

            var storeData = function(){
                var json = drawnItems.toGeoJSON();
                $('#'+mapDataContainer).val(JSON.stringify(json));
            };

            var addGeoJson = function (json) {
                var geojsonLayer = L.geoJson(json, {
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
                });
                geojsonLayer.eachLayer(function(l){
                    drawnItems.addLayer(l);
                });
                if (drawnItems.getLayers().length > 0) {
                    map.fitBounds(drawnItems.getBounds());
                }
            };

            var data = $('#'+mapDataContainer).val();
            if (data.length > 0){
                var json = JSON.parse(data);
                addGeoJson(json);
            }

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
                drawnItems.addLayer(layer);
                storeData();
            });
            map.on(L.Draw.Event.DELETED, function (event) {
                var data = drawnItems.toGeoJSON();
                storeData();
            });
        </script>
        {/literal}

    </div>
{/default}
