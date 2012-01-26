{ezpagedata_set( 'extra_menu', false() )}
<div class="border-box">
<div class="border-tl"><div class="border-tr"><div class="border-tc"></div></div></div>
<div class="border-ml"><div class="border-mr"><div class="border-mc float-break">

<div class="content-view-full">
    <div class="class-folder">

        {if $rss_export}
        <div class="attribute-rss-icon">
            <a href="{concat( '/rss/feed/', $rss_export.access_url )|ezurl( 'no' )}" title="{$rss_export.title|wash()}"><img src="{'rss-icon.gif'|ezimage( 'no' )}" alt="{$rss_export.title|wash()}" /></a>
        </div>
        {/if}

        <div class="attribute-header">
            <h1>{attribute_view_gui attribute=$node.data_map.name}</h1>
        </div>

        {if eq( ezini( 'folder', 'SummaryInFullView', 'content.ini' ), 'enabled' )}
            {if $node.object.data_map.short_description.has_content}
                <div class="attribute-short">
                    {attribute_view_gui attribute=$node.data_map.short_description}
                </div>
            {/if}
        {/if}

        {if $node.object.data_map.description.has_content}
            <div class="attribute-long">
                {attribute_view_gui attribute=$node.data_map.description}
            </div>
        {/if}

        {if $node.object.data_map.show_children.data_int}
            {def $page_limit = 10
                 $classes = ezini( 'MenuContentSettings', 'ExtraIdentifierList', 'menu.ini' )
                 $children = array()
                 $children_count = ''}
                 
            {if le( $node.depth, '3')}
                {set $classes = $classes|merge( ezini( 'ChildrenNodeList', 'ExcludedClasses', 'content.ini' ) )}
            {/if}

            {set $children_count=fetch_alias( 'children_count', hash( 'parent_node_id', $node.node_id,
                                                                      'class_filter_type', 'exclude',
                                                                      'class_filter_array', $classes ) )}

            <div class="content-view-children">
                {if $children_count}
                	{ezscript_require( array( 'http://maps.google.com/maps/api/js?sensor=true', 'ezjsc::jquery', 'jqueryui.js', 'jquery.ui.map.min.js', 'ocmap.js'))}
                	<script type="text/javascript">
                	{literal}
                	$(document).ready( function(){
                	    $('#map_canvas').ocmap();
                	});
                	{/literal}
                	</script>

                    <div id="map_canvas" style="width:100%;height:300px"></div>
                    <div id="map_filters">
                    	<input class="select" type="checkbox" value="prova" />prova <br />
                    	<input class="select" type="checkbox" value="test" />test <br />
                    	<input class="select" type="checkbox" value="ez" />ez
                    </div>
                    <div id="map_data">
                    	{def $filter_attributes = array( 'tags' )}
                    	{node_view_gui view='map' content_node=$node filter_attributes=$filter_attributes}
                    </div>

                    
                {/if}
            </div>

            {include name=navigator
                     uri='design:navigator/google.tpl'
                     page_uri=$node.url_alias
                     item_count=$children_count
                     view_parameters=$view_parameters
                     item_limit=$page_limit}

        {/if}
    </div>
</div>

</div></div></div>
<div class="border-bl"><div class="border-br"><div class="border-bc"></div></div></div>
</div>