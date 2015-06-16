Скрипт для визуализации логов запросов тайлов с сервера openstreetmap.org

Сделано на основе статьи http://lukasmartinelli.ch/python/2015/05/24/parsing-and-visualizing-osm-access-logs.html.
Логи публикуются по адресу http://planet.openstreetmap.org/tile_logs. Каждый день представлен отдельным архивированым текстовым файлом из строк вида 

0/0/0 588590
1/0/0 139613

В нём записаны адрес тайла, и количество его запросов. В файле указываются только те тайлы, которые были запрошенны более 10 раз за день.
Этот набор скриптов занимается загрузкой пачки дампов в базу PostGIS. В базе записывается полигональная геометрия тайла, и суммарное количество запросов за все дни. 

Сначала запускаем скрипт для скачивания дампов. Когда докачается достаточно дампов, например на месяц май - остановите скачку Ctrl+C

./download_stats.sh

Далее один раз выполняем первую часть обработки - распаковываем архив, заменяем во всех файлах символ / на пробел, переименовываем файлы в csv.

unxz dumps/tile_logs/*.xz
sed -i 's/\// /g' dumps/tile_logs/*.txt
rename 's/\.txt$/\.csv/' dumps/tile_logs/*.txt

Теперь работаем со скриптом tile_stat_polygons.sh - он занимается загрузкой логов в базу данных PostGIS.
Откройте скрипт tile_stat_polygons.sh и укажите в переменных параметры доступа к своей базе данных и zoom.
Откройте скрипт filter_area.py, и укажите в нём bbox, в котором будут считаться запросы.

Запустите скрипт 
./tile_stat_polygons.sh

Возможно придётся сделать скрипты *.py и *.sh исполняемыми.


Отобразить результат можно разными способами. Нагляднее всего открыть таблицу в QGIS, и задать раскраску по диапазонам с режимом "Квантили". Подложить в QGIS OSM проще всего плагином QuickMapServices.

Демо

Для публикации результатов в интернете я воспользовался имеющимся у меня инстансом NextGIS Web (на момент написания текста просто так попробовать его нельзя, нужно обязательно инсталировать его на какой-нибудь сервер с Ubuntu). 
NGW принимает геоданные в формате Shapefile, поэтому в конце скрипта добавлен экспорт из PostGIS в Shapefile.

Пример: http://demo.nextgis.ru/ngw/resource/1949/display?base=osm-mapnik&bbox=4077915.4584464,7353143.4205415,4490981.159242,7630456.9591215&styles=1951
