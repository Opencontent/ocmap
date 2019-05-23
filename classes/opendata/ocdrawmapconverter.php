<?php

use Opencontent\Opendata\Api\AttributeConverter\Base;

class OCDrawMapConverter extends Base
{
	public function get( eZContentObjectAttribute $attribute )
    {        
        $content = parent::get($attribute);
        $attributeContent = $attribute->attribute('content');
        $attributeContent['geo_json'] = json_decode($attributeContent['geo_json'], 1);
        $content['content'] = $attributeContent;
        return $content;
    }
}