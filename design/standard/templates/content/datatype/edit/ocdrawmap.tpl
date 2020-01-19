{default attribute_base='ContentObjectAttribute' html_class='full' placeholder=false()}

{run-once}
{ezcss_require(array(
    'leaflet/leaflet.0.7.2.css',
    'leaflet/geocoder/Control.Geocoder.css',
    'leaflet/Control.Loading.css',
    'leaflet.draw.css',
    'spectrum.css'
))}
{ezscript_require(array(
    'leaflet/leaflet.0.7.2.js',
    'ezjsc::jquery',
    'leaflet/Control.Loading.js',
    'leaflet/geocoder/Control.Geocoder.js',
    'leaflet.draw.js',
    'leaflet-osm-data.js',
    'leaflet/Leaflet.MakiMarkers.js',
    'spectrum.js',
    'jquery.ocdrawmap.js'
))}
{/run-once}
<div id="ocdrawmap-{$attribute.id}">
    <div class="map" style="width: 100%; height: 600px; margin: 10px 0"></div>

    <div class="float-break clearfix" style="margin: 10px 0">

        <label>
            {'Color'|i18n('ocdrawmap/attribute')}:
        </label>
        <div class="block">
            <input type='text'
                       class="Form-input map-color"
                       name="{$attribute_base}_ocdrawmap_osm_color_{$attribute.id}"
                       value="{if $attribute.content.color}{$attribute.content.color}{else}#3388ff{/if}" />
       </div>

        <label>
            {'Import from url'|i18n('ocdrawmap/attribute')}:
        </label>
        <em class="attribute-description">{'Example for OSM full XML: https://www.openstreetmap.org/api/0.6/relation/2220827/full'|i18n('ocdrawmap/attribute')}</em>
        <div class="block">
            <div class="element">
                <select class="map-import-type form-control"
                        name="{$attribute_base}_ocdrawmap_osm_type_{$attribute.id}">
                    <option></option>
                    <option value="osm" {if $attribute.content.type|eq('osm')}selected="selected"{/if}>Openstreet map full xml</option>
                    <option value="geojson" {if $attribute.content.type|eq('geojson')}selected="selected"{/if}>GeoJSON</option>
                </select>
            </div>
            <div class="element">
                <input class="box map-import-url form-control"
                       name="{$attribute_base}_ocdrawmap_osm_url_{$attribute.id}"
                       value="{$attribute.content.source|wash()}"
                       type="text"/>
            </div>
            <div class="element">
                <input class="button map-import-submit btn btn-info btn-sm" type="submit" id="import-osm-url"
                       name="CustomActionButton[{$attribute.id}_ocdrawmap_save_osm_url]"
                       value="{'Import'|i18n( 'design/standard/content/datatype' )}" />
                <a href="#" class="map-reset btn btn-danger btn-sm">{'Reset'|i18n( 'design/standard/content/datatype' )}</a>
            </div>
        </div>
    </div>

    <label>
        {'GeoJSON Data'|i18n('ocdrawmap/attribute')}:
    </label>
    <div class="block float-break clearfix">
        <textarea class="map-data form-control" name="{$attribute_base}_ocdrawmap_data_text_{$attribute.id}">{$attribute.content.geo_json|wash()}</textarea>
    </div>

    <style>
        .leaflet-div-icon {ldelim}
            background: #fff !important;
            border: 1px solid #666 !important;
        {rdelim}
    </style>
    <script>
        $(document).ready(function(){ldelim}
            $('#ocdrawmap-{$attribute.id}').oceditmap();
            {rdelim});
    </script>
</div>
{/default}
