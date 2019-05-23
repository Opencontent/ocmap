<?php

class ocSolrDocumentFieldGmapLocation extends ezfSolrDocumentFieldGmapLocation
{
    public static $subattributesDefinition = array( 
    	self::DEFAULT_SUBATTRIBUTE => 'text',
    	'wkt' => 'location_rpt',
        'coordinates' => 'geopoint',
        'geohash' => 'geohash',
        'latitude' => 'float',
        'longitude' => 'float' 
    );

    private $isLocationRptEnabled;

    function __construct( eZContentObjectAttribute $attribute )
    {
        parent::__construct( $attribute );
        $this->isLocationRptEnabled = OCDrawMapType::addSolrFieldTypeMap();
    }


    public static function getFieldName( eZContentClassAttribute $classAttribute, $subAttribute = null, $context = null )
    {
        OCDrawMapType::addSolrFieldTypeMap();
        if ( $subAttribute and
             $subAttribute !== '' and
             array_key_exists( $subAttribute, self::$subattributesDefinition ) and
             $subAttribute != self::DEFAULT_SUBATTRIBUTE )
        {
            return parent::generateSubattributeFieldName( $classAttribute,
                                                          $subAttribute,
                                                          self::$subattributesDefinition[$subAttribute] );
        }
        else
        {
            return parent::generateAttributeFieldName( $classAttribute,
                                                       self::$subattributesDefinition[self::DEFAULT_SUBATTRIBUTE] );
        }
    }

    public static function getFieldNameList( eZContentClassAttribute $classAttribute, $exclusiveTypeFilter = array() )
    {
        OCDrawMapType::addSolrFieldTypeMap();
        
        // Generate the list of subfield names.
        $subfields = array();

        //   Handle first the default subattribute
        $subattributesDefinition = self::$subattributesDefinition;
        if ( !in_array( $subattributesDefinition[self::DEFAULT_SUBATTRIBUTE], $exclusiveTypeFilter ) )
        {
            $subfields[] = parent::generateAttributeFieldName( $classAttribute, $subattributesDefinition[self::DEFAULT_SUBATTRIBUTE] );
        }
        unset( $subattributesDefinition[self::DEFAULT_SUBATTRIBUTE] );

        //   Then hanlde all other subattributes
        foreach ( $subattributesDefinition as $name => $type )
        {
            if ( empty( $exclusiveTypeFilter ) or !in_array( $type, $exclusiveTypeFilter ) )
            {
                $subfields[] = parent::generateSubattributeFieldName( $classAttribute, $name, $type );
            }
        }
        return $subfields;
    }

    static function getClassAttributeType( eZContentClassAttribute $classAttribute, $subAttribute = null, $context = 'search' )
    {
        OCDrawMapType::addSolrFieldTypeMap();

        if ( $subAttribute and
             $subAttribute !== '' and
             array_key_exists( $subAttribute, self::$subattributesDefinition ) )
        {
            return self::$subattributesDefinition[$subAttribute];
        }
        else
        {
            return self::$subattributesDefinition[self::DEFAULT_SUBATTRIBUTE];
        }
    }

    public function getData()
    {
    	$data = parent::getData();
    	if ($this->isLocationRptEnabled) {
            $contentClassAttribute = $this->ContentObjectAttribute->attribute('contentclass_attribute');
            if (isset($data[self::getFieldName($contentClassAttribute, 'coordinates')])) {
                $coords = explode(',', $data[self::getFieldName($contentClassAttribute, 'coordinates')]);
                $data[self::getFieldName($contentClassAttribute, 'wkt')] = $coords[1] . ' ' . $coords[0];
            }
        }

    	return $data;
    }
}
