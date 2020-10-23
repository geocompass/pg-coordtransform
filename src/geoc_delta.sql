CREATE OR REPLACE FUNCTION "public"."geoc_delta"("lon" numeric, "lat" numeric)
  RETURNS "pg_catalog"."jsonb" AS $BODY$
DECLARE
    ret             varchar;
    dLon            numeric;
    dlat            numeric;
    radLat          numeric;
    magic           numeric;
    sqrtMagic       numeric;
    ee              numeric;
    a               numeric;
BEGIN
    ee := 0.006693421622965823;
    a  := 6378245;
    dLon := geoc_transform_lon(lon - 105, lat - 35);
    dLat := geoc_transform_lat(lon - 105, lat - 35);
    radLat := lat / 180 * pi();
    magic = sin(radLat);

    magic = 1 - ee * magic * magic;

    sqrtMagic := sqrt(magic);
    dLon = (dLon * 180) / (a / sqrtMagic * cos(radLat) * pi());
    dLat = (dLat * 180) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi());
    ret :='['||dLon||','||dLat||']';
	return ret::jsonb;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;