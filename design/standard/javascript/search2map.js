(function($) {

    $.search2map = function(options) {
        
        //start initialize script with Google method
        google.setOnLoadCallback(initialize);
            
        var settings = $.extend(
        {
            mapId: 'map',
            infoWindowId:'',
            center: [0, 0],
            zoom: 1,
            filters: [],
            data: null,
            baseUrl: '',            
            clusterMaxZoom:1,
            clusterGridSize:60,
            markersPath:'',
            useFilters: null,
            filtersId: 'filters',
            debug: false
        }, options );
        
        var query = $.extend(
        {
            querySlug: 'default',
            queryIcon: '',                        
            infoWindowAbstractAttributes: ['intro'],
            infoWindowLocationAttribute: 'geo',
            infoWindowImageSize: 'small',
            useImageForMarkers: '',            
            SearchStr:'',
            SearchOffset:'',
            SearchLimit:'',
            SearchContentClassAttributeID:'',
            SearchContentClassID:'',
            SearchContentClassIdentifier:'',
            SearchSubTreeArray:'',
            SearchSectionID:'',
            SearchDate:'',
            SearchTimestamp:'',
            EnableSpellCheck:'',
            GetFacets:'',
            Filters:'',
            EncodingFetchChildrenCount:'',
            EncodingFetchSection:'',
            EncodingFormatDate:'',
            EncodingLoadImages:'',
            EncodingDataMapAttribute:[],
            EncodingDataMapTypeAttribute:[],
            EncodingImagePreGenerateSizes:['small'],
            UseSqlFetch:'',
            PrintQuery:'',
            CallbackID:'',
            CacheNode:0,
            CacheExpiry:0
        }, options.query, {markersPath:settings.markersPath});

        var map = null;
        var geocoder = new google.maps.Geocoder();
        var bounds; 
        
        /* Data handler */
        
        var data = [];
        
        function addData(newdata, reset){
            if (reset != 'undefined')
                data = [];
            if ( newdata.length == undefined){
                data.push(newdata);
            }else{
                $.extend(data,newdata);
            }
        }
        
        function getData(){
            var returnData = [];
            var filters_ = getActiveFilters();
            var tmpData = [];
            
            if (settings.debug) console.log(data);
            if ( filters_.length > 0 ){
                for (var f = 0; f < filters_.length; f++) {
                    for (var d = 0; d < data.length; d++) {
                        if ( data[d].filter == filters_[f] ){
                            for (var i = 0; i < data[d].objects.length; i++) {
                                returnData.push( data[d].objects[i] );
                            }
                        }
                    }
                }
            }else{
                for (var d = 0; d < data.length; d++) {
                    for (var i = 0; i < data[d].objects.length; i++) {
                        returnData.push( data[d].objects[i] );
                    }
                }
            }   
            return returnData;
        }

        function findDataObject( i )
        {
            var d = getData();
            if ( d[i] )
                return d[i];
            return false;
        }        
        
        /* Filters */
        
        var filters = [];
        
        function addFilters(array){
            $.extend(filters,array);
        }
        
        function addFilter(key){
            filters.push(key);
        }
        
        function removeFilter(key){
            for (var f = 0; f < filters.length; f++) {
                if (filters[f] == key) {
                    filters.splice(f, 1);
                }
            }
        }
        
        function getActiveFilters(){
            return filters;
        }
        
        /* Markers */
        
        var markers = [];
        var infowindow = new google.maps.InfoWindow({maxWidth:350});
        
        function getMarkers(){  
            var _data = getData();
            if (_data.length) {
                for (var d = 0; d < _data.length; d++) {
                    var object = _data[d];
                    var coordinate = new google.maps.LatLng( object.location[0], object.location[1] );
                    
                    var markerImage = new google.maps.MarkerImage(object.icon, new google.maps.Size(24, 32));
                    
                    markers[d] = new google.maps.Marker({
                        title: object.name,                
                        position: coordinate,
                        zIndex: 0                        
                    });
                    bounds.extend(coordinate);
                    if ( object.icon != 'default' ){
                        markers[d].icon = object.icon
                    }
                    
                    if (object.text && (object.showInfo > 0) ){
                        markers[d].zIndex = 1;   
                        if ( settings.infoWindowId == ''){
                            google.maps.event.addListener(  markers[d], 'click', (function(mrk, txt) {
                                return function() {                                    
                                    infowindow.setContent(txt);
                                    infowindow.open(map, mrk);
                                }
                            })( markers[d], object.text));
                        }else{
                            google.maps.event.addListener(  markers[d], 'click', (function(mrk, txt, index, mrks) {
                                return function() {                                    
                                    customInfoWindow(mrk, txt, index, mrks);
                                    map.setCenter( mrk.position );
                                    map.setZoom(7);
                                }
                            })( markers[d], object.text, d, markers));
                        }
                    }                    
                }
                if (settings.debug) console.log("markers.length = " + markers.length);
                return markers;
            }
            return [];
        }
        
        function customInfoWindow(mrk, txt, index, mrks){
            geocoder.geocode({'latLng': mrk.position}, function(results, status) {                                        
                var address = '';
                if (status == google.maps.GeocoderStatus.OK) {
                    if (results[1]) {
                        address = results[1].formatted_address;                                                
                    }                                            
                    $('#'+settings.infoWindowId).html( txt + '<p>' + address + '</p>').show();
                }else{
                    $('#'+settings.infoWindowId).html( txt ).show();
                }                

                var p = index - 1;
                var prev = $('<a class="ui-btn-left ui-btn ui-btn-icon-notext ui-btn-corner-all ui-shadow ui-btn-up-b"><span class="ui-btn-inner ui-btn-corner-all"><span class="ui-btn-text">Precedente</span><span class="ui-icon ui-icon-arrow-l ui-icon-shadow"></span></span></a>');                   
                if ( mrks[p] )
                {
                    prev.bind('click', function(){                                                            
                        var txt = findDataObject(p);
                        customInfoWindow( mrks[p], txt.text, p, mrks );
                        map.setCenter( mrks[p].position );
                        map.setZoom(7);
                        return false;
                    });
                    prev.appendTo($('#'+settings.infoWindowId));
                }             

                var n = index + 1;        
                var next = $('<a class="ui-btn-right ui-btn ui-btn-icon-notext ui-btn-corner-all ui-shadow ui-btn-up-b"><span class="ui-btn-inner ui-btn-corner-all"><span class="ui-btn-text">Successivo</span><span class="ui-icon ui-icon-arrow-r ui-icon-shadow"></span></span></a>');                
                if ( mrks[n] )
                {
                    next.bind('click', function(){                                                            
                        var txt = findDataObject(n);
                        customInfoWindow( mrks[n], txt.text, n, mrks );
                        map.setCenter( mrks[n].position );
                        map.setZoom(7);
                        return false;
                    });
                    next.appendTo($('#'+settings.infoWindowId));                    
                }                
            });              
        }
        
        /* Query */
        
        function buildQuery(queryVars, reset){            
            $.ez('search2map::search', queryVars, function(d){
                
                if (settings.debug) console.log(d);                
                
                if (queryVars.GetFacets != ''){
                    
                    var searchExtras = d.content.SearchExtras;
                    
                    var resetLinks = $('<div id="searchExtras-default" class="search-facet float-break" />');
                    var cloneQueryVars = $.extend({}, queryVars);
                    var newQuery = $.extend(cloneQueryVars, {GetFacets:'',Filters:'',querySlug:'default'});                    
                    $('<p class="searchExtras active" />')
                        .text('[x]')
                        .bind('click', {query: newQuery}, function(e){
                            $('.searchExtras').not($(this)).removeClass('active');
                            $(this).addClass('active');
                            buildQuery(e.data.query, true);
                        })
                        .appendTo(resetLinks);
                    resetLinks.prependTo( $('#'+settings.filtersId) );
                    
                    for (var f = 0; f < searchExtras.facets.length; f++) {
                        var facetLinksContainer = $('<div><h2>'+searchExtras.facets[f].name+'</h2></div>');
                        $('h2', facetLinksContainer).bind('click', function(){
                            $('*','#'+settings.filtersId).removeClass('open');
                            $(this).next().addClass('open');
                            $(this).parent().addClass('open');
                        });
                        var facetLinks = $('<ul id="searchExtras-'+searchExtras.facets[f].name+'" class="search-facet float-break" />');;
                        for (var l = 0; l < searchExtras.facets[f].list.length; l++) {                                
                            var cloneQueryVars = $.extend({}, queryVars);
                            var newQuery = $.extend(cloneQueryVars, {GetFacets:'',querySlug:'facet'+searchExtras.facets[f].list[l].value, Filters:searchExtras.facets[f].list[l].params});
                            $('<li class="searchExtras" />')
                                .text(searchExtras.facets[f].list[l].value)
                                .bind('click', {query: newQuery}, function(e){
                                    $('.searchExtras').not($(this)).removeClass('active');
                                    $(this).addClass('active');
                                    buildQuery(e.data.query, true);
                                })
                                .appendTo(facetLinks);
                        }
                        facetLinks.appendTo(facetLinksContainer);
                        facetLinksContainer.appendTo( $('#'+settings.filtersId) );
                    }
                }
                
                var queryResult = {
                    'filter': queryVars.querySlug,
                    'icon' : 'default', 
                    'objects': []
                }
                
                if (d.content.SearchResultCount > 0){
                    queryResult.objects = d.content.SearchResult;
                }
                
                addData(queryResult, reset);
                refreshMap();
            });
        }
        
        /* Map */
        
        function refreshMap() {
            for (i in markers) {
                markers[i].setMap(null);
            }
            markers.length = 0;
            infowindow.close();
            markerClusterer.clearMarkers();
            map.setZoom(settings.zoom);
            map.setCenter(new google.maps.LatLng( settings.center[0], settings.center[1] ));
            markers = getMarkers();
            if ( markers.length ){
	            markerClusterer.addMarkers(markers);            
	            map.setCenter( bounds.getCenter() );
	            map.fitBounds( bounds );
            }
        }
        
        /* initialize */
        
        function initialize(){
            
            
            $(document).ajaxSend(function() {
                $('#'+settings.mapId ).css('opacity', '0.5');
            });
            $(document).ajaxStop(function() {
                $('#'+settings.mapId ).css('opacity', '1');
            });
            
            map = new google.maps.Map(document.getElementById(settings.mapId),
            {
                center: new google.maps.LatLng( settings.center[0], settings.center[1] ),
                zoom: settings.zoom,
                panControl: false,
                zoomControl: true,
                scaleControl: true,
                maxZoom:15,
                minZoom:2,
                mapTypeControl:false,
                streetViewControl:false,
                scrollwheel:false,
                mapTypeId: google.maps.MapTypeId.HYBRID
            });            
            
            markerClusterer = new MarkerClusterer(map, [], {gridSize: settings.clusterGridSize, maxZoom:settings.clusterMaxZoom});
            
            bounds = new google.maps.LatLngBounds();
            
            if (settings.filters.length > 0){
                addFilters(settings.filters);
            }
            if (settings.data != null){
                addData(settings.data);
            }
            if (query != null){
                buildQuery(query);
            }
            if (settings.useFilters){
                if ( $('#'+settings.filtersId ).length < 1 ){
                    $('<div id="'+settings.filtersId+'" />').after( $('#'+settings.mapId) );
                }else{
                    var cloneQueryVars = $.extend({}, query); 
                    $('li', '#'+settings.filtersId).bind('click', {query: cloneQueryVars}, function(e){
                        $('.searchExtras').not($(this)).removeClass('active');
                        $(this).addClass('active');
                        var field = $(this).parent().attr('default');
                        var newQuery = $.extend(e.data.query, {GetFacets:'',querySlug:$(this).parent().attr('default')+$(this).attr('default'),Filters:[$(this).parent().attr('default'),$(this).attr('default')] }); 
                        buildQuery(newQuery, true);
                    });
                }
                $('h2','#'+settings.filtersId).bind('click', function(){
                    $('*','#'+settings.filtersId).removeClass('open');
                    $(this).next().addClass('open');
                    $(this).parent().addClass('open');
                });
            }
            
            $("#select-map").bind('change', function(){
                var type = $(this).val();                
                if ( type == 'ROADMAP')
                    map.setMapTypeId(google.maps.MapTypeId.ROADMAP);
                else if ( type == 'HYBRID')
                    map.setMapTypeId(google.maps.MapTypeId.HYBRID);
                else if ( type == 'SATELLITE')
                    map.setMapTypeId(google.maps.MapTypeId.SATELLITE);
            });            
        }       
    }

})(jQuery);