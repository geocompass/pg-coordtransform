<h1 align="center">Welcome to pg-coordtransform 👋</h1>
<p>
  <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="78" height="20"><linearGradient id="b" x2="0" y2="100%"><stop offset="0" stop-color="#bbb" stop-opacity=".1"/><stop offset="1" stop-opacity=".1"/></linearGradient><clipPath id="a"><rect width="78" height="20" rx="3" fill="#fff"/></clipPath><g clip-path="url(#a)"><path fill="#555" d="M0 0h51v20H0z"/><path fill="#007ec6" d="M51 0h27v20H51z"/><path fill="url(#b)" d="M0 0h78v20H0z"/></g><g fill="#fff" text-anchor="middle" font-family="DejaVu Sans,Verdana,Geneva,sans-serif" font-size="110"> <text x="265" y="150" fill="#010101" fill-opacity=".3" transform="scale(.1)" textLength="410">version</text><text x="265" y="140" transform="scale(.1)" textLength="410">version</text><text x="635" y="150" fill="#010101" fill-opacity=".3" transform="scale(.1)" textLength="170">1.0</text><text x="635" y="140" transform="scale(.1)" textLength="170">1.0</text></g> <script xmlns=""/></svg>
</p>

> coordtransform function base on PostgreSQL and PostGIS. support WGS84 GCJ02 BD09
## Example
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

## How to use
```
PostgreSQL安装PostGIS扩展
复制geoc-pg-coordtansform.sql中代码，在数据库执行
```
# Who use/Who star

- 阿里巴巴（digoal,德哥）

- [CTOLib码库](https://javascript.ctolib.com/geocompass-pg-coordtransform.html)

- 国信司南

- 九天气象（lzuniujp08）

- 深圳普天宜通股份有限公司（ShareQiu1994）

- 中原百科（zhongyuanbaike）

- MonsterBOBO（hanrea）

- nocode（sanford）


## Author

👤 **LH  QQ:1016817543**

👤 **Wangsb  QQ:1017218804**

* Github: [@MrSmallLiu](https://github.com/MrSmallLiu)

## 🤝 Contributing

Contributions, issues and feature requests are welcome!<br />Feel free to check [issues page](https://github.com/geocompass/pg-coordtransform/issues).

## Show your support

Give a ⭐️ if this project helped you!

***
