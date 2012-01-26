{def $geoattribute = false()}

{foreach $node.object.contentobject_attributes as $attribute}
	{if $attribute.data_type_string|eq( 'ezgmaplocation' )}
		{set $geoattribute = $attribute.contentclass_attribute_identifier}
		{skip}
	{/if}
{/foreach}


{if $geoattribute}
{def $attribute = $node.data_map.$geoattribute
	 $latitude  = $attribute.content.latitude|explode(',')|implode('.')
     $longitude = $attribute.content.longitude|explode(',')|implode('.')
     $address = $attribute.content.address}
<div class="content-view-mapline marker-container ">
    {def $tags = 'all'}
    {foreach $filter_attributes as $attribute_identifier}
	    {if and( is_set( $node.data_map.$attribute_identifier ), $node.data_map.$attribute_identifier.has_content )}
		    {switch match=$node.data_map.$attribute_identifier.data_type_string}
		    	{case match='ezkeyword'}
		    	 	{set $tags = concat( $tags, '|', $node.data_map.$attribute_identifier.content.keywords|implode('|') )}
			    {/case}
			    {case match='ezrelationlist'}
			    {/case}
			    {case}
			    {/case}
		    {/switch}
	    {/if}
    {/foreach}
    <div data-gmapping='{ldelim}"id":"node_{$node.node_id}","latlng":{ldelim}"lat":{$latitude},"lng":{$longitude}{rdelim},"tags":"{$tags}","icon":"{class_icon( small, $node.class_identifier, true() )}"{rdelim}'>
		<div class="info-box">
			{if is_set( $node.url_alias )}
				<h2><a href="{$node.url_alias|ezurl('no')}" title="{$node.name|wash()}"><span class="icon">{class_icon( 'small', $node.class_identifier )}</span> {$node.name|wash()}</a></h2>
			{else}
				<h2><span class="icon">{class_icon( 'small', $node.class_identifier )}</span> {$node.name|wash()}</h2>
			{/if}
			<p>{$tags}</p>
			<p><span class="lat">{$latitude}</span></p>
			<p><span class="lng">{$longitude}</span></p>
			<p><span class="address">{$address}</span></p>		
		</div>
    </div>
</div>
{undef $attribute $latitude $longitude $address $tags}
{/if}