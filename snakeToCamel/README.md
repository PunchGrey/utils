
snakeToCamel
====================

Утилита создаёт новый файл на основе текстового файла со списком имен в формате:

    bacula
    beats
    ccr_mi
    config_db_geobank

в формат:

    bacula  prefixBacula
    beats   prefixBeats
    ccr_mi  prefixCcrMi
    config_db_geobank   prefixConfigDbGeobank

Новый файл каждый раз перезаписывается.

Применение
----------

    snakeToCamel -in /tmp/fileIn.txt -out /tmp/fileOut.txt -pref pm
        опции:
            -in путь к файлу с данными
                значение по умолчанию /home/galchenko/projects/adm/create_repo_gitea/nameRepos.txt
            -out путь к файлу с преобразованными именами
                значение по умолчанию /home/galchenko/projects/adm/create_repo_gitea/newNameRepos.txt
            -pref префикс, который добавляется к имени
                значение по умолчанию пустая строка
        исходный файл /home/galchenko/projects/adm/create_repo_gitea/nameRepos.txt:
            bacula
            beats
            ccr_mi
            config_db_geobank
        итоговый файл /home/galchenko/projects/adm/create_repo_gitea/newNameRepos.txt:
            bacula  pmBacula
            beats   pmBeats
            ccr_mi  pmCcrMi
            config_db_geobank   pmConfigDbGeobank
