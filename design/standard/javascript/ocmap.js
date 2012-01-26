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
					data.content = $(el).find('.info-box').text();
					$this.gmap('addMarker', {'id': data.id, 'content': data.content, 'icon': data.icon, 'tags':data.tags, 'position': new google.maps.LatLng(data.latlng.lat, data.latlng.lng), 'bounds':true }).click(function() {
						$this.gmap('openInfoWindow', { 'content': $(this)[0].content }, this);
					});
				});
		    	$(".select").bind( 'click', function(){
			    	if ( $(".select:checked").length == 0){
			    		$this.gmap('find', 'markers', { 'property': 'tags', 'value': 'all', 'delimiter': '|' }, function(marker, found) {
							marker.setVisible(true); 
							$this.gmap('addBounds', marker.position);	
						});
			    	}else{
		        	    $(".select:checked").each(function(i,el) {
							$this.gmap('find', 'markers', { 'property': 'tags', 'value': $(el).val(), 'delimiter': '|' }, function(marker, found) {
								if (found) {
									$this.gmap('addBounds', marker.position);
								}
								marker.setVisible(found); 
							});
		    	    	});
			    	}
				});
		    }).load();
    	});
    }
	
})(jQuery);