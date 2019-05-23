# Opencontent Map

## Per abilitare la ricerca su mappa

Verificare la presenza della libreria `spatial4j-0.4.1.jar` 

Aggiungere in `schema.xml` di solr all'interno di `types`

```
<fieldType name="location_rpt"   class="solr.SpatialRecursivePrefixTreeFieldType"
   spatialContextFactory="com.spatial4j.core.context.jts.JtsSpatialContextFactory"
   distErrPct="0.025"
   maxDistErr="0.000009"
   units="degrees"
/>
```

Aggiungere in `schema.xml` di solr all'interno di `fields`

```
<dynamicField name="*_rpt" type="location_rpt"  indexed="true"  stored="true" multiValued="true"/>
<dynamicField name="*____rpt" type="location_rpt"  indexed="true" stored="true" multiValued="true"/>
```

Aggiungere in `ezfind.ini`

```
[SolrFieldMapSettings]
CustomMap[ocdrawmap]=ocSolrDocumentFieldOCDrawMap
DatatypeMap[ocdrawmap]=location_rpt
```
