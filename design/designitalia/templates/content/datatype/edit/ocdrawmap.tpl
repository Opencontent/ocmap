{default attribute_base='ContentObjectAttribute' html_class='full' placeholder=false()}
<div class="Form-field{if $attribute.has_validation_error} has-error{/if}">
    <label class="Form-label {if $attribute.is_required}is-required{/if}" for="ezcoa-{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}">
        {first_set( $contentclass_attribute.nameList[$content_language], $contentclass_attribute.name )|wash}
        {if $attribute.is_information_collector} <em class="collector">{'information collector'|i18n( 'design/admin/content/edit_attribute' )}</em>{/if}
        {if $attribute.is_required} ({'richiesto'|i18n('design/ocbootstrap/designitalia')}){/if}
    </label>

    {if $contentclass_attribute.description}
        <em class="attribute-description">{first_set( $contentclass_attribute.descriptionList[$content_language], $contentclass_attribute.description)|wash}</em>
    {/if}

{run-once}
{ezcss_require(array(
    'leaflet/leaflet.0.7.2.css',
    'leaflet/geocoder/Control.Geocoder.css',
    'leaflet/Control.Loading.css',
    'leaflet.draw.css',
    'spectrum.css'
))}
{ezscript_require(array(
    'leaflet.0.7.2.js',
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
            
            <label class="Form-label">
                {'Color'|i18n('ocdrawmap/attribute')}:
            </label>

            <div class="Grid Grid--withGutter">
                <div class="Grid-cell">
                    <input type='text' 
                           class="Form-input map-color"                           
                           name="{$attribute_base}_ocdrawmap_osm_color_{$attribute.id}"
                           value="{if $attribute.content.color}{$attribute.content.color}{else}#3388ff{/if}" />
                </div>
            </div>

            <label class="Form-label">
                {'Import from url'|i18n('ocdrawmap/attribute')}:
            </label>
            <em class="attribute-description">{'Example for OSM full XML: https://www.openstreetmap.org/api/0.6/relation/2220827/full'|i18n('ocdrawmap/attribute')}</em>
            <div class="Grid Grid--withGutter">
                <div class="Grid-cell u-size2of12 u-sm-size2of12 u-md-size2of12 u-lg-size2of12">
                    <select class="Form-input map-import-type"
                            name="{$attribute_base}_ocdrawmap_osm_type_{$attribute.id}">
                        <option></option>
                        <option value="osm" {if $attribute.content.type|eq('osm')}selected="selected"{/if}>Openstreet map full xml</option>
                        <option value="ocql_geo" {if $attribute.content.type|eq('ocql_geo')}selected="selected"{/if}>Opencontent Geo API</option>
                    </select>
                </div>
                <div class="Grid-cell u-size8of12 u-sm-size8of12 u-md-size8of12 u-lg-size8of12">
                    <input class="Form-input map-import-url"                           
                           name="{$attribute_base}_ocdrawmap_osm_url_{$attribute.id}"
                           value="{$attribute.content.source|wash()}"
                           type="text"/>
                </div>                
                <div class="Grid-cell u-size2of12 u-sm-size2of12 u-md-size2of12 u-lg-size2of12" style="padding-top: 10px">
                    <button class="btn map-import-submit" 
                            type="submit"
                            {if $attribute.content.source|ne('')}style="display: none;"{/if}
                            name="CustomActionButton[{$attribute.id}_ocdrawmap_save_osm_url]">
                        {'Import'|i18n( 'design/standard/content/datatype' )}
                    </button>
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
