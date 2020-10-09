CREATE OR REPLACE FUNCTION "public"."geoc_bd09towgs84"("geom" "public"."geometry")
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
			return geoc_bd09towgs84_line(geom);
		when 'ST_MultiLineString' then 
			return geoc_bd09towgs84_multiline(geom);
		when 'ST_Point' then 
			return geoc_bd09towgs84_point(geom);
		when 'ST_MultiPoint' then 
			return geoc_bd09towgs84_multipoint(geom);
		when 'ST_Polygon' then 
			return geoc_bd09towgs84_polygon(geom);
		when 'ST_MultiPolygon' then
			return geoc_bd09towgs84_multipolygon(geom);
		ELSE
     		RETURN null;
	END CASE;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;