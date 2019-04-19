package main

import (
	"fmt"
	"gopkg.in/yaml.v2"
	"io/ioutil"
	"os"
	"path/filepath"
	"text/template"
)

func check(e error) {
	if e != nil {
		panic(e)
	}
}

func main() {
	if len(os.Args) != 3 {
		fmt.Println("Usage:", os.Args[0], "<template.tpl> <conf.yml>")
		os.Exit(1)
	}

	t_functions := template.FuncMap{
		"add": func(nums ...int) int {
			total := 0
			for _, num := range nums {
				total += num
			}
			return total
		},
		"sub": func(nums ...int) int {
			residue := nums[0]
			for _, num := range nums[1:] {
				residue -= num
			}
			return residue
		},
	}
	dat, err := ioutil.ReadFile(os.Args[2])
	check(err)
	m := make(map[interface{}]interface{})
	err = yaml.Unmarshal(dat, &m)
	check(err)
	t := template.Must(template.New(filepath.Base(os.Args[1])).Funcs(t_functions).ParseFiles(os.Args[1]))
	err = t.Execute(os.Stdout, m)
	check(err)
}
