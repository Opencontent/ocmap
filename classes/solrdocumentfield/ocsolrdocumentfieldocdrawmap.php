<?php

class ocSolrDocumentFieldOCDrawMap extends ezfSolrDocumentFieldBase
{

	public static function getFieldName(eZContentClassAttribute $classAttribute, $subAttribute = null, $context = 'search')
    {
        OCDrawMapType::addSolrFieldTypeMap();
        switch ($classAttribute->attribute('data_type_string')) {
            case OCDrawMapType::DATA_TYPE_STRING:
                return self::generateAttributeFieldName(
                    	$classAttribute,
                        self::getClassAttributeType($classAttribute, null, $context)
                    );
                break;

            default:
                return null;
                break;
        }
    }

    public function getData()
    {		
		$data = array();
		$contentClassAttribute = $this->ContentObjectAttribute->attribute('contentclass_attribute');
		$fieldName = self::getFieldName($contentClassAttribute);
		$WKTList = OCDrawMapType::getWKTList($this->ContentObjectAttribute);
		foreach ($WKTList as $item) {
			$data[$fieldName][] = $item;
		}
    	return $data;
    }

}
