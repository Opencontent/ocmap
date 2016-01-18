{def $geoattribute = false()
     $tag_object = array()}

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
     $address = $attribute.content.address
}

    {def $tags = 'all'
         $icon = false()}

    {if is_set($filter_attributes)}
    {foreach $filter_attributes as $attribute_identifier}

	    {if and( is_set( $node.data_map.$attribute_identifier ), $node.data_map.$attribute_identifier.has_content )}
		    {switch match=$node.data_map.$attribute_identifier.data_type_string}
		    	{case match='ezkeyword'}
		    	 	{set $tags = concat( $tags, '|', $node.data_map.$attribute_identifier.content.keywords|implode('|') )}
			    {/case}
			    {case match='ezrelationlist'}
			 
			    {/case}
			    {case match='ezobjectrelationlist'}
				    {foreach $node.data_map.$attribute_identifier.content.relation_list as $item}
					     {set $tag_object = fetch('content', 'object',  hash( 'object_id', $item.contentobject_id))}
					     {set $tags = concat($tags, '|',$tag_object.id)}
					     {set $icon = cond( and( is_set( $tag_object.data_map.image ), $tag_object.data_map.image.has_content ), $tag_object.data_map.image, false() )}
				    {/foreach}
			    {/case}

			    {case}
			    {/case}
		    {/switch}
	    {/if}
    {/foreach}
    {/if}
    
    {if and( $latitude, $longitude )}
    <div class="content-view-mapline marker-container ">
    <div data-gmapping='{ldelim}"id":"node_{$node.node_id}","latlng":{ldelim}"lat":{$latitude},"lng":{$longitude}{rdelim},"tags":"{$tags}","icon":"{if $icon}{$icon.content.marker.full_path|ezroot('no')}{else}{'default_marker.png'|ezimage(no)}{/if}"{rdelim}' class="hide">
		<div class="info-box">
            <p>
                <a href="{$node.url_alias|ezurl('no')}" title="{$node.name|wash()}">
                    <strong>{$node.name|wash()}</strong>
                </a>    
            </p>
            
            {if is_set($filter_attributes)}
                <small>
                {foreach $filter_attributes as $attribute_identifier}
                    {if is_set( $node.data_map.$attribute_identifier )}
                        <strong>{$node.data_map.$attribute_identifier.contentclass_attribute_name}:</strong>
                        {attribute_view_gui attribute=$node.data_map.$attribute_identifier image_class=small href='nolink'}
                        <br />
                    {/if}
                {/foreach}
                </small>
            {/if}
            
            {if and( is_set($node.data_map.image), $node.data_map.image.has_content )}
            <div class="object-left">{attribute_view_gui attribute=$node.data_map.image image_class=small}</div>
            {/if}
            {if $node|has_abstract()}
            {$node|abstract()}
            {/if}
		</div>
    </div>
    </div>
    {/if}

{undef $attribute $latitude $longitude $address $tags}
{/if}