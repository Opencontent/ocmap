(function ($) {
    $.fn.ocmap = function (options) {
        var settings = $.extend({
            'center': [0, 0],
            'zoom': 7
        }, options);

        this.each(function (options) {
            var $this = $(this);

            var map = new L.Map($this[0], {
                zoom: settings.zoom,
                center: new L.latLng(settings.center[0], settings.center[1])
            });
            map.scrollWheelZoom.disable();
            L.tileLayer('//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a>'
            }).addTo(map);

            var collection = {
                "type": "FeatureCollection",
                "features": []
            };
            $("[data-gmapping]").each(function (i, el) {
                var data = $(el).data('gmapping');
                collection.features.push({
                    "type": "Feature",
                    "properties":
                        {
                            'id': data.id,
                            'content': $(el).find('.info-box').html(),
                            'icon': data.icon,
                            'tags': data.tags,
                            'bounds': true
                        },
                    "geometry":
                        {
                            "type": "Point",
                            "coordinates": [data.latlng.lng, data.latlng.lat]
                        }
                });
            });

            var pointToLayer = function (feature, latlng) {
                return L.marker(latlng, {
                    icon: L.icon({
                        iconUrl: feature.properties.icon
                    })
                });
            };

            var data = L.geoJson(null, {
                pointToLayer: function (feature, latlng) {
                    return pointToLayer(feature, latlng);
                },
                onEachFeature: function (feature, layer) {
                    layer.bindPopup(feature.properties.content);
                }
            });
            data.addData(collection);

            var group = new L.FeatureGroup([]);
            group.addLayer(data);
            group.addTo(map);
            if (data.getLayers().length > 0) {
                map.fitBounds(group.getBounds(), {padding: [10, 10]});
            }

            $(".select").bind('change', function () {
                var selected = [];
                $(".select").each(function (i, el) {
                    var $el = $(el);
                    var span = $el.siblings('span');
                    if ($el.is(':checked')) {
                        span.addClass('selected');
                        selected.push($el.val());
                    } else {
                        span.removeClass('selected');
                    }
                });
                map.removeLayer(group);
                group.clearLayers();

                data = L.geoJson(null, {
                    pointToLayer: function (feature, latlng) {
                        return pointToLayer(feature, latlng);
                    },
                    onEachFeature: function (feature, layer) {
                        layer.bindPopup(feature.properties.content);
                    },
                    filter: function (feature, layer) {
                        var tags = feature.properties.tags.split('|');
                        var intersect = $.map(tags, function (el) {
                            return $.inArray(el, selected) < 0 ? null : el;
                        });
                        return intersect.length > 0;
                    }
                });
                data.addData(collection);
                group.addLayer(data);
                group.addTo(map);
                if (data.getLayers().length > 0) {
                    map.fitBounds(group.getBounds(), {padding: [10, 10]});
                }
            });
        });
    }
})(jQuery);