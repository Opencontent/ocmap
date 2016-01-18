{if is_set( $parent_node_id )|not()}
    {def $parent_node_id = ezini( 'NodeSettings', 'RootNode', 'content.ini' )}
{/if}
{if is_set( $class )|not()}
    {def $class = 'luogo'}
{/if}
{if is_set( $height )|not()}
    {def $height = '300px'}
{/if}
{if is_set( $width )|not()}
    {def $width = '100%'}
{/if}
{if is_set( $limit )|not()}
    {def $limit = 5000}
{/if}

{def $map_search_hash = hash( 'subtree_array', array( $parent_node_id ),
                              'class_id', array( $class ),
                              'limit', $limit )}


{def $map_news = fetch( ezfind, search, $map_search_hash )}

{if $map_news.SearchCount}

<div id="content-research-map">

    <script type="text/javascript" src='http://maps.google.com/maps/api/js?sensor=true'></script>
    {ezscript_require( array( 'ezjsc::jquery', 'jquery.ui.map.min.js', 'ocmap.js'))}
    <script type="text/javascript">
    {literal}
    $(document).ready( function(){
        $('#map_canvas').ocmap();
        $('#filter_toggle').bind( 'click', function(){
            $('#map_filters input').each( function(){
                $(this).trigger( 'change' );
                $(this).trigger( 'click' );
            });
            return false;
        });
    });
    {/literal}
    </script>
    <div id="map_canvas" style="width:{$width};height:{$height};"></div>
        
    <div id="map_data">
        {foreach $map_news.SearchResult as $result}
            {node_view_gui view='map_line' content_node=$result}
        {/foreach}
    </div>

</div>    
{/if}
