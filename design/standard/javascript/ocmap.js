(function($) {
    $.fn.ocmap = function( options ) {
    	
    	var settings = $.extend( {
    		'center': [0, 0],
    		'zoom': 7    		
	    }, options);
    	
    	this.each( function( options ) {
    		var $this = $(this);
		    $this.gmap( options ).bind('init', function () {                    		    	
                $("[data-gmapping]").each(function(i,el) {					
                    var data = $(el).data('gmapping');                    
					data.content = $(el).find('.info-box').html();
					$this.gmap('addMarker', {'id': data.id, 'content': data.content, 'icon': data.icon, 'tags':data.tags, 'position': new google.maps.LatLng(data.latlng.lat, data.latlng.lng), 'bounds':true }).click(function() {
						$this.gmap('openInfoWindow', { 'content': $(this)[0].content }, this);
					});
				});
		    	
                $(".select").bind( 'change', function(){
	
                    target_array = [];

                    $(".select").each(function(i,el) {
                        span = $(el).siblings( 'span' );
                        if ( $(el).is(':checked') )
                            span.addClass('selected');
                        else
                            span.removeClass('selected');
                        $this.gmap('find', 'markers', { 'property': 'tags', 'value': $(el).val(), 'delimiter': '|' }, function(marker, found) {
                            if (found && $(el).is(':checked') ) {
                                target_array.push(marker);
                            }
                            marker.setVisible(false);
                        });
                    });
    
                    for(var i in target_array){
                        $this.gmap('addBounds', target_array[i].position);
                        target_array[i].setVisible(true);
                    }
                
				});
                
		    }).load();
    	});
    }
	
})(jQuery);