package main

import (
	"fmt"
	"net/http"
	"os"

	"go.elastic.co/apm/module/apmhttp"
)

func main() {
	// read enviroments
	envs := os.Environ()
	for _, env := range envs {
		fmt.Println(env)
	}

	mux := http.NewServeMux()

	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("Hello, Elastic APM!"))
	})

	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("OK"))
	})

	http.ListenAndServe(":8080", apmhttp.Wrap(mux))
}
