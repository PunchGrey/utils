# Миграция с svn в git

Для упрощения миграции используется скрипт createRepoGitea.sh. Он, используя файл fileIn, где перечислены имена svn репозиториев (snake case), создаёт git репозитории (формат имен camel case), делает push ветки master. Для простых случаев этого достаточно. Если есть ветвление или тэгирование, то нужно будет доделывать миграцию в ручном режиме. Скрипт использует утилиту написанную на go snakeToCamel и api gitea.

## Простая конфигурация. Используем скрипт createRepoGitea.sh

Параметры скрипта:

* rootFolder - путь к рутовой папке, там будет создан локальный git репозиторий.
  * пример: "/home/user/projects/puppet/testgit"
* fileIn - путь к файлу с перечисленными svn репозиториями
  * пример:"/home/user/projects/adm/create_repo_gitea/nameRepos.txt"
* fileOut - путь по которому будет создан новый файл с именами git репозиториев.
  * пример: "/home/user/projects/adm/create_repo_gitea/newNameRepos.txt"
* prefix - префикс, который будет добовляться к именам git репозиториям
  * пример для паппет-модулей: "pm"
* fileUsers - файл с сопостовлением имен пользователей svn и git
  * для уточнения пользователей в svn используется команду svn log --xml | grep author | sort -u | perl -pe 's/.*>(.*?)<.*/$1 = /' > nameFile.txt
  * пример: "/home/user/projects/puppet/testgit/modules/users.txt"
* token - токен для работы с api gitea
* userName - пользователь от которого будут создаваться репозитории в git
  * Пример: user
* userPass - пароль пользователя
* description - описание для git репозиториев
  * пример: "puppet module"
* nameOrg - название организации в которой будет создаваться git репозиторий
  * пример: "amd"
* svnUrl - url путь к svn репозиторию до имени приложения (не включительно)
  * пример: "svn://yoursvn/puppet/modules"
* gitUrl - url путь к gitea
  * пример: "http://git.yourdomain.name"
* idTeam - id команды в которую добавится репозиторий
  * пример  "11"

### Запускаем скрипт на примере pmDocker

Создаём файл fileIn с записью docker (имя папки в svn):

    echo "docker" > /home/user/projects/adm/create_repo_gitea/nameRepos.txt

Создаём файл fileUser /home/user/projects/puppet/testgit/modules/users.txt:

    user = user <user@domain.name>

Задаём параметры скрипта createRepoGitea.sh:

    rootFolder="/home/user/projects/puppet/testgit"
    fileIn="/home/user/projects/adm/create_repo_gitea/nameRepos.txt"
    fileOut="/home/user/projects/adm/create_repo_gitea/newNameRepos.txt"
    fileUsers="/home/user/projects/puppet/testgit/modules/users.txt"
    prefix="pm"
    token="yourToken"
    userName="yourUser"
    userPass="yourPass"
    description="puppet module"
    nameOrg = "adm"
    svnUrl = "svn://yoursvn"
    gitUrl="http://git.yourdomain.name"
    idTeam = "11"

Заходим в папку, где лежит скрипт createRepoGitea.sh, там же должна быть утилита snakeToCamel:

    cd /home/user/projects/adm/create_repo_gitea/
    user@WolfWork:~/projects/adm/create_repo_gitea$ ls
    createRepoGitea.sh  nameRepos.txt  newNameRepos.txt  README.md  snakeToCamel  tempNameRepos.txt

Запускаем скрипт:

    ./createRepoGitea.sh

Должен появиться локальный репозиторий /home/user/projects/puppet/testgit/docker и синхронизированная ветка master

## Сложная конфигурация с ветвлением и тэгированием

### Создаём branch на примере webServTask

Запускаем скрипт с измененными параметрами (подробнее в разделе запуск скрипта на примере pmDocker):

    rootFolder="/home/user/projects/puppet/testgit"
    fileIn="/home/user/projects/adm/create_repo_gitea/nameRepos.txt"
    fileOut="/home/user/projects/adm/create_repo_gitea/newNameRepos.txt"
    fileUsers="/home/user/projects/adm/create_repo_gitea/users.txt"
    prefix=""
    token="yourToken"
    userName="yourName"
    userPass="yourPass"
    description="web api"
    nameOrg="test"
    svnUrl="svn://yoursvn"
    gitUrl="http://git.yourdomain.name"
    idTeam = "11"

В итоге получаем git репозиторий и синхронизированную ветку master. Смотрим какие есть ветки:

    user@WolfWork:~/projects/puppet/testgit/webServTask$ git branch -a
    * master
    remotes/origin/autotransforming_and_metadata
    remotes/origin/export_metadata
    remotes/origin/python3
    remotes/origin/tags/0.0.1
    remotes/origin/tags/0.4.1
    remotes/origin/tags/0.6.0
    remotes/origin/tags/new_build
    remotes/origin/trunk

Переключаемся на ветку remotes/origin/python3:

    user@WolfWork:~/projects/puppet/testgit/webServTask$ git checkout --track remotes/origin/python3
    Ветка python3 отслеживает внешнюю ветку python3 из origin.
    Переключено на новую ветку «python3»

Делаем push на сервер:

    git push origin python3

Теперь у нас на сервере появилась ветка python3

### Создаём tag на примере webServTask

Переходим на ветку master:

    user@WolfWork:~/projects/puppet/testgit/webServTask$ git checkout master
    Переключено на ветку «master»

Создаём tag:

    user@WolfWork:~/projects/puppet/testgit/webServTask$ git tag -a v0.4.1 remotes/origin/tags/0.4.1

Проверяем tag:

    user@WolfWork:~/projects/puppet/testgit/webServTask$ git tag
    v0.4.1

Делаем push релиза на сервер:

    user@WolfWork:~/projects/puppet/testgit/webServTask$ git push origin v0.4.1

Теперь у нас на сервер появился релиз v0.4.1