CREATE OR REPLACE FUNCTION "public"."geoc_wgs84togcj02"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
		i                 geometry;
		transform_i       geometry;
		multiArr          geometry[]; 
	
BEGIN
IF st_srid(geom) != '4490' and  st_srid(geom) != '4326'THEN
        RETURN null;
end if;
 	CASE ST_GeometryType(geom)
    	when 'ST_LineString' then 
			return geoc_wgs84togcj02_line(geom);
		when 'ST_MultiLineString' then 
			return geoc_wgs84togcj02_multiline(geom);
		when 'ST_Point' then 
			return geoc_wgs84togcj02_point(geom);
		when 'ST_MultiPoint' then 
			return geoc_wgs84togcj02_multipoint(geom);
		when 'ST_Polygon' then 
			return geoc_wgs84togcj02_polygon(geom);
		when 'ST_MultiPolygon' then
			return geoc_wgs84togcj02_multipolygon(geom);
		ELSE
     		RETURN null;
	END CASE;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;