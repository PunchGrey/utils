package main

import (
	"bufio"
	"flag"
	"log"
	"os"
	"strings"
)

func main() {
	var (
		pathIn  = flag.String("in", "/home/galchenko/projects/adm/create_repo_gitea/nameRepos.txt", "the fail with data")
		prefix  = flag.String("pref", "", "the prefix for new names in the outfile")
		pathOut = flag.String("out", "/home/galchenko/projects/adm/create_repo_gitea/newNameRepos.txt", "the fail with new data")
	)
	flag.Parse()

	fileIn, err := os.Open(*pathIn)
	if err != nil {
		log.Fatal(err)
	}
	defer fileIn.Close()

	fileOut, err := os.OpenFile(*pathOut, os.O_CREATE|os.O_TRUNC|os.O_WRONLY, 0644)
	if err != nil {
		log.Fatal(err)
	}
	defer fileOut.Close()

	scanner := bufio.NewScanner(fileIn)
	for scanner.Scan() {
		bufString := scanner.Text() + "\t" + SnakeToCamel(scanner.Text(), *prefix) + "\n"
		_, err = fileOut.WriteString(bufString)
		if err != nil {
			log.Fatal(err)
		}
	}

}

//SnakeToCamel по строке в формате змейки строит строку кэмелкейса
func SnakeToCamel(strIn string, prefix string) string {
	var strOut = prefix
	strSlice := strings.Split(strIn, "_")
	for i, item := range strSlice {
		if prefix != "" {
			strOut = strOut + strings.Title(item)
		} else {
			if i == 0 {
				strOut = strOut + item
			} else {
				strOut = strOut + strings.Title(item)
			}
		}
	}
	return strOut
}
