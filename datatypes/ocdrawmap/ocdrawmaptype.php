<?php

class OCDrawMapType extends eZDataType
{
    const DATA_TYPE_STRING = 'ocdrawmap';

    function __construct()
    {
        $this->eZDataType(self::DATA_TYPE_STRING, ezpI18n::tr('kernel/classes/datatypes', 'Draw Map', 'Datatype name'),
            array(
                'serialize_supported' => true,
                'object_serialize_map' => array('data_text' => 'text')
            )
        );
    }

    /**
     * @param eZContentObjectAttribute $contentObjectAttribute
     * @param int $currentVersion
     * @param eZContentObjectAttribute $originalContentObjectAttribute
     */
    function initializeObjectAttribute($contentObjectAttribute, $currentVersion, $originalContentObjectAttribute)
    {
        if ($currentVersion != false) {
            $dataText = $originalContentObjectAttribute->attribute("data_text");
            $contentObjectAttribute->setAttribute("data_text", $dataText);
        } else {
            $contentClassAttribute = $contentObjectAttribute->contentClassAttribute();
            $default = $contentClassAttribute->attribute('data_text1');
            if ($default !== '' && $default !== NULL) {
                $contentObjectAttribute->setAttribute('data_text', $default);
            }
        }
    }

    /**
     * @param eZContentObjectAttribute $contentObjectAttribute
     * @return string
     */
    function objectAttributeContent($contentObjectAttribute)
    {
        $content = array(
            'type' => '',
            'color' => '',
            'source' => '',
            'geo_json' => json_encode(new \Opencontent\Opendata\GeoJson\FeatureCollection()),
        );
        $data = $contentObjectAttribute->attribute('data_text');
        if ($data != ''){
            $content = json_decode($data, 1);
        }

        return $content;
    }

    /**
     * @param eZContentObjectAttribute $contentObjectAttribute
     * @return bool
     */
    function hasObjectAttributeContent($contentObjectAttribute)
    {
        return trim($contentObjectAttribute->attribute('data_text')) != '';
    }

    /**
     * @param eZHTTPTool $http
     * @param $base
     * @param eZContentObjectAttribute $contentObjectAttribute
     * @return bool
     */
    function fetchObjectAttributeHTTPInput($http, $base, $contentObjectAttribute)
    {
        if ($http->hasPostVariable($base . '_ocdrawmap_data_text_' . $contentObjectAttribute->attribute('id'))) {
            $geoJSON = $http->postVariable($base . '_ocdrawmap_data_text_' . $contentObjectAttribute->attribute('id'));
            $content = array(
                'geo_json' => $geoJSON
            );
            if ($http->hasPostVariable($base . '_ocdrawmap_osm_url_' . $contentObjectAttribute->attribute('id'))) {
                $content['source'] = $http->postVariable($base . '_ocdrawmap_osm_url_' . $contentObjectAttribute->attribute('id'));
            }
            if ($http->hasPostVariable($base . '_ocdrawmap_osm_type_' . $contentObjectAttribute->attribute('id'))) {
                $content['type'] = $http->postVariable($base . '_ocdrawmap_osm_type_' . $contentObjectAttribute->attribute('id'));
            }
            if ($http->hasPostVariable($base . '_ocdrawmap_osm_color_' . $contentObjectAttribute->attribute('id'))) {
                $content['color'] = $http->postVariable($base . '_ocdrawmap_osm_color_' . $contentObjectAttribute->attribute('id'));
            }
            $contentObjectAttribute->setAttribute('data_text', json_encode($content));
            return true;
        }
        return false;
    }

    function isIndexable()
    {
        return true;
    }

    function metaData($contentObjectAttribute)
    {
        return '';
    }

    /**
     * @param eZContentObjectAttribute $contentObjectAttribute
     * @return string
     */
    function toString($contentObjectAttribute)
    {
        return $contentObjectAttribute->attribute('data_text');
    }

    /**
     * @param eZContentObjectAttribute $contentObjectAttribute
     * @param $string
     */
    function fromString($contentObjectAttribute, $string)
    {
        $contentObjectAttribute->setAttribute( 'data_text', $string );
    }

}

eZDataType::register( OCDrawMapType::DATA_TYPE_STRING, 'OCDrawMapType' );

