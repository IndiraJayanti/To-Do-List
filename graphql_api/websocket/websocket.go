// todo_fullstack/graphql_api/websocket/websocket.go
package websocket

import (
	"log"
	"net/http"
	"sync"
	"time"
	"github.com/gorilla/websocket"
)

// Message represents a discussion message
type Message struct {
	Username string `json:"username"`
	Content  string `json:"content"`
	Timestamp string `json:"timestamp"`
}

var (
	upgrader = websocket.Upgrader{
		ReadBufferSize:  1024,
		WriteBufferSize: 1024,
		CheckOrigin: func(r *http.Request) bool {
			// Allow all origins for development. In production, be more restrictive.
			return true
		},
	}
	clients   = make(map[*websocket.Conn]bool) // Connected clients
	broadcast = make(chan Message)             // Channel for broadcasting messages
	mu        sync.Mutex                       // Mutex to protect clients map
)

// HandleConnections handles new websocket connections
func HandleConnections(w http.ResponseWriter, r *http.Request) {
	ws, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("Error upgrading to websocket: %v", err)
		return
	}
	defer ws.Close()

	mu.Lock()
	clients[ws] = true
	mu.Unlock()

	log.Printf("Client connected: %s", ws.RemoteAddr().String())

	for {
		var msg Message
		err := ws.ReadJSON(&msg)
		if err != nil {
			log.Printf("Error reading json from client %s: %v", ws.RemoteAddr().String(), err)
			mu.Lock()
			delete(clients, ws)
			mu.Unlock()
			log.Printf("Client disconnected: %s", ws.RemoteAddr().String())
			break
		}
		// Add timestamp to the message
		msg.Timestamp = time.Now().Format("15:04:05") // HH:MM:SS format
		broadcast <- msg
	}
}

// HandleMessages listens on the broadcast channel and sends messages to all clients
func HandleMessages() {
	for {
		msg := <-broadcast
		log.Printf("Broadcasting message: %v", msg)
		mu.Lock()
		for client := range clients {
			err := client.WriteJSON(msg)
			if err != nil {
				log.Printf("Error writing json to client %s: %v", client.RemoteAddr().String(), err)
				client.Close()
				delete(clients, client)
			}
		}
		mu.Unlock()
	}
}

// InitWebSocket initializes the WebSocket message handler
func InitWebSocket() {
	go HandleMessages()
}