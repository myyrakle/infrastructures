package main

import (
	"fmt"
	"log"
	"net/http"
	"time"
)

func main() {
	server := &http.Server{
		Addr:              ":8080",
		ReadHeaderTimeout: 5 * time.Second,
		Handler: http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			userAgent := r.UserAgent()
			fmt.Println(userAgent)
			w.Header().Set("Content-Type", "text/plain; charset=utf-8")
			fmt.Fprintln(w, userAgent)
		}),
	}
	log.Fatal(server.ListenAndServe())
}
