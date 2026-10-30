package main

import (
	"encoding/json"
	"log"
	"net/http"
)

var version = "dev"

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]string{
			"status": "ok",
			"message": version,
		})	
	})
	log.Printf("iot-app:%s Listening on port :8888", version)
	log.Fatal(http.ListenAndServe(":8888", nil))
}