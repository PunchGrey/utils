#/bin/bash

rootFolder="/home/testgit"
fileIn="/home/nameRepos.txt"
fileOut="/home/newNameRepos.txt"
fileUsers="/home/users.txt"
prefix=""
token="your_token"
userName="user"
userPass="pass"
description="web api"
nameOrg="test"
svnUrl="svn://your_url"

./snakeToCamel -in $fileIn -out $fileOut -pref "${prefix}"

cd $rootFolder

while IFS= read -r line; 
do 
    IFS="	" read -ra nameRepo <<< "$line"
    nameDir=${nameRepo[0]}
    nameRepo=${nameRepo[1]}
    
    curl -X POST "http://git.srv.sec45.ccr.dep4.niitp/api/v1/org/${nameOrg}/repos?access_token=${token}" -H "accept: application/json" -H "content-type: application/json" -d "{\"name\":\"${nameRepo}\", \"description\": \"${description}\" }"
    curl -X PUT "http://git.srv.sec45.ccr.dep4.niitp/api/v1/teams/11/repos/${nameOrg}/${nameRepo}?access_token=${token}" -H "accept: application/json" -H "content-type: application/json"

    git svn clone --authors-file=$fileUsers --username $userName --no-metadata --stdlayout ${svnUrl}/${nameDir} $nameDir  #удалил trunk
    cd $nameDir
    git filter-branch --commit-filter 'git_commit_non_empty_tree "$@"' HEAD
    git svn create-ignore
    git branch -rd git-svn
    git conig --remove-section svn-remote.svn
    git config --remove-section svn
    rm -rf .git/svn
    git gc
    git remote add origin http://git.srv.sec45.ccr.dep4.niitp/${nameOrg}/${nameRepo}.git
    git push -u http://${userName}:${userPass}@git.srv.sec45.ccr.dep4.niitp/${nameOrg}/${nameRepo}.git master
    cd ..
done < $fileOut
