<?php

class OCMapMarkersGeoJsonFeatureCollection
{
    public $type = 'FeatureCollection';
    public $features = array();
    public $featuresIndex = array();

    public function add(OCMapMarkersGeoJsonFeature $feature)
    {
        if (!isset($this->featuresIndex[$feature->id]))
        {
            $this->featuresIndex[$feature->id] = $feature;
            $this->features[] = $feature;
        }
    }
}

class OCMapMarkersGeoJsonFeature
{
    public $type = "Feature";
    public $id;
    public $properties;
    public $geometry;

    public function __construct($id, array $geometryArray, array $properties)
    {
        $this->id = $id;

        $this->geometry = new OCMapMarkersGeoJsonGeometry();
        $this->geometry->coordinates = $geometryArray;

        $this->properties = new OCMapMarkersGeoJsonProperties($properties);
    }
}

class OCMapMarkersGeoJsonGeometry
{
    public $type = "Point";
    public $coordinates;
}

class OCMapMarkersGeoJsonProperties
{
    public function __construct(array $properties = array())
    {
        foreach ($properties as $key => $value) {
            $this->{$key} = $value;
        }
    }
}