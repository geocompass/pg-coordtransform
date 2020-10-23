CREATE OR REPLACE FUNCTION "public"."geoc_wgs84tobd09_polygon"("source_geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
    target_parts    geometry[];
    source_npoints  integer;
    single_line     geometry;
    single_line_trans geometry;
    single_polygon  geometry;
    final_geom      geometry;

BEGIN
    IF ST_GeometryType(source_geom) != 'ST_Polygon' THEN
        RETURN null;
    END IF;

    FOR single_polygon IN SELECT ST_ExteriorRing ((st_dumprings($1)).geom) as geom LOOP				
        source_npoints := ST_NPoints(single_polygon); 
        single_line  := ST_RemovePoint(single_polygon, source_npoints - 1);  
        single_line_trans := geoc_wgs84tobd09_line(single_line);  
        target_parts := array_append(target_parts, ST_AddPoint(single_line_trans, ST_PointN(single_line_trans, 1)));  
    END LOOP;
    SELECT ST_MakePolygon(target_parts[1], target_parts[2:array_upper(target_parts, 1)]) INTO final_geom;  

    RETURN final_geom;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;