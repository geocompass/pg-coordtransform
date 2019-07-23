# pg-coordtransform
基于PostgreSQL+PostGIS的坐标转换函数,支持点、线、面的WGS84与GCJ02坐标互转

## 示例
```sql
GCJ02转WGS84
select geoc_gcj02towgs84(geom) from test_table
WGS84转GCJ02
select geoc_wgs84togcj02(geom) from test_table
```

## 如何安装
```
PostgreSQL安装PostGIS扩展
复制geoc_gcj02_wgs84.sql中代码，在数据库执行

```

