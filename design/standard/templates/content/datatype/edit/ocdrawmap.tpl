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
    'leaflet.js',
    'ezjsc::jquery',
    'leaflet/Control.Loading.js',
    'leaflet/geocoder/Control.Geocoder.js',
    'leaflet.draw.js',
    'leaflet-osm-data.js',
    'Leaflet.MakiMarkers.js',
    'spectrum.js',
    'jquery.ocdrawmap.js'
))}
{/run-once}
    <div id="ocdrawmap-{$attribute.id}">
        <div class="map" style="width: 100%; height: 600px; margin: 10px 0"></div>

        <div style="margin: 10px 0">
            
            <label>
                {'Import from url'|i18n('ocdrawmap/attribute')}:
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
                    <select class="map-import-type"
                            name="{$attribute_base}_ocdrawmap_osm_type_{$attribute.id}">
                        <option></option>
                        <option value="osm" {if $attribute.content.type|eq('osm')}selected="selected"{/if}>Openstreet map full xml</option>
                        <option value="ocql_geo" {if $attribute.content.type|eq('ocql_geo')}selected="selected"{/if}>Opencontent Geo API</option>
                    </select>
                </div>
                <div class="element">
                    <input class="box map-import-url"                           
                           name="{$attribute_base}_ocdrawmap_osm_url_{$attribute.id}"
                           value="{$attribute.content.source|wash()}"
                           type="text"/>
                </div>
                <div class="element">
                    <input class="button map-import-submit" type="submit" id="import-osm-url"
                           {if $attribute.content.source|ne('')}style="display: none;"{/if}
                           name="CustomActionButton[{$attribute.id}_ocdrawmap_save_osm_url]"
                           value="{'Import'|i18n( 'design/standard/content/datatype' )}" />
                </div>
            </div>
        </div>

        <input class="map-data"
               type="hidden"
               name="{$attribute_base}_ocdrawmap_data_text_{$attribute.id}"
               value="{$attribute.content.geo_json|wash()}" />
    </div>
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

    
{/default}
