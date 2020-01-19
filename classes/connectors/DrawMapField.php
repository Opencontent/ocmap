<?php

use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\FieldConnector;

class DrawMapField extends FieldConnector
{
    public function getData()
    {
        $data = parent::getData();
        $data['geo_json'] = !empty($data['geo_json']) ? json_encode($data['geo_json']) : null;

        return $data;
    }

    public function getSchema()
    {
        return array(
            "title" => $this->attribute->attribute('name'),
            'required' => (bool)$this->attribute->attribute('is_required'),
        );
    }

    public function getOptions()
    {
        return array(
            "helper" => $this->attribute->attribute('description'),
            "type" => 'drawmap',
            "i18n" => [
                'type' => ezpI18n::tr('ocdrawmap/attribute', "Source type"),
                'color' => ezpI18n::tr('ocdrawmap/attribute', "Color"),
                'source' => ezpI18n::tr('ocdrawmap/attribute', "Import from url"),
                'geo_json' => ezpI18n::tr('ocdrawmap/attribute', "GeoJSON Data"),
                'types' => [
                    'geojson' => 'GeoJSON',
                    'osm' => 'Openstreet map full xml',
                ]
            ]
        );
    }

    public function setPayload($postData)
    {
        return json_encode($postData);
    }
}
