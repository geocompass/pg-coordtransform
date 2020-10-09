CREATE OR REPLACE FUNCTION "public"."geoc_cgcs2000togcj02"("geom" "public"."geometry")
  RETURNS "public"."geometry" AS $BODY$
DECLARE
BEGIN
IF st_srid(geom) != '4490' THEN
        RETURN null;
end if;
return geoc_wgs84togcj02(st_transform(st_setsrid(geom,4490),4326));
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;