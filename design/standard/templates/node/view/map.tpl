{foreach fetch_alias( 'children', hash( 'parent_node_id', $node.node_id,
                                         'offset', $#view_parameters.offset,
                                         'sort_by', $node.sort_array,
                                         'class_filter_type', 'exclude',
                                         'class_filter_array', $#classes,
                                         'limit', $#page_limit ) ) as $child }
    {node_view_gui view='map_line' content_node=$child filter_attributes=$filter_attributes}
{/foreach}