CREATE OR REPLACE FUNCTION "public"."geoc_gcj02tobd09"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
BEGIN
IF st_srid(geom) != '4490' and  st_srid(geom) != '4326'THEN
        RETURN null;
end if;
case ST_GeometryType(geom)
    when 'ST_LineString' then 
			return geoc_gcj02tobd09_line(geom);
	when 'ST_MultiLineString' then 
		return geoc_gcj02tobd09_multiline(geom);
	when 'ST_Point' then 
		return geoc_gcj02tobd09_point(geom);
	when 'ST_MultiPoint' then 
			return geoc_gcj02tobd09_multipoint(geom);
	when 'ST_Polygon' then 
			return geoc_gcj02tobd09_polygon(geom);
	when 'ST_MultiPolygon' then
		return geoc_gcj02tobd09_multipolygon(geom); 
	ELSE
    	RETURN null;
END CASE;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;