# pg-coordtransform
基于PostgreSQL+PostGIS的坐标转换函数,支持点、线、面的WGS84、GCJ02、BD09坐标互转

## 示例
```sql
GCJ02转WGS84
select geoc_gcj02towgs84(geom) from test_table
WGS84转GCJ02
select geoc_wgs84togcj02(geom) from test_table
WGS84转BD09
select geoc_wgs84tobd09(geom) from test_table
BD09转WGS84
select geoc_bd09towgs84(geom) from test_table
GCJ02转BD09
select geoc_gcj02tobd09(geom) from test_table
BD09转GCJ02
select geoc_bd09togcj02(geom) from test_table
```

## 如何安装
```
PostgreSQL安装PostGIS扩展
复制geoc-pg-coordtansform.sql中代码，在数据库执行

```

## *与作者联系*
*QQ:1016817543*


