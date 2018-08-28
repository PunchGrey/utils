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
gitUrl="http://git.yourdomain.name"
idTeam = "11"
idTeam2 = ""

./snakeToCamel -in $fileIn -out $fileOut -pref "${prefix}"

cd $rootFolder

while IFS= read -r line; 
do 
    IFS="	" read -ra nameRepo <<< "$line"
    nameDir=${nameRepo[0]}
    nameRepo=${nameRepo[1]}
    
    curl -X POST "${gitUrl}/api/v1/org/${nameOrg}/repos?access_token=${token}" -H "accept: application/json" -H "content-type: application/json" -d "{\"name\":\"${nameRepo}\", \"description\": \"${description}\" }"
    if [ -n "$idTeam" ]   
    then
        curl -X PUT "http://git.srv.sec45.ccr.dep4.niitp/api/v1/teams/${idTeam}/repos/${nameOrg}/${nameRepo}?access_token=${token}" -H "accept: application/json" -H "content-type: application/json"
    fi
    if [ -n "$idTeam2" ]   
    then
        curl -X PUT "http://git.srv.sec45.ccr.dep4.niitp/api/v1/teams/${idTeam2}/repos/${nameOrg}/${nameRepo}?access_token=${token}" -H "accept: application/json" -H "content-type: application/json"
    fi

    git svn clone --authors-file=$fileUsers --username $userName --no-metadata --stdlayout ${svnUrl}/${nameDir} $nameDir  #удалил trunk
    cd $nameDir
    git filter-branch --commit-filter 'git_commit_non_empty_tree "$@"' HEAD
    git svn create-ignore
    git branch -rd git-svn
    git conig --remove-section svn-remote.svn
    git config --remove-section svn
    rm -rf .git/svn
    git gc
    git remote add origin ${gitUrl}/${nameOrg}/${nameRepo}.git
    git push -u http://${userName}:${userPass}@${gitUrl}/${nameOrg}/${nameRepo}.git master
    cd ..
done < $fileOut
