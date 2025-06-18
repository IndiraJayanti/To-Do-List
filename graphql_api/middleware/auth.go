package middleware

import (
	"context"
	"encoding/json"
	"fmt"
	"graphql_api/graph/model" // Pastikan import model
	"log"
	"net/http"
	"strings"

	"github.com/golang-jwt/jwt/v5"
)

// UserContextKey is a key for the user in the context
type UserContextKey string

const userCtxKey UserContextKey = "user"

// GraphQLResponseError merepresentasikan struktur error GraphQL
type GraphQLResponseError struct {
	Message    string                 `json:"message"`
	Extensions map[string]interface{} `json:"extensions,omitempty"`
}

// GraphQLResponse merepresentasikan respons error GraphQL
type GraphQLResponse struct {
	Errors []GraphQLResponseError `json:"errors"`
}

// AuthMiddleware decodes the JWT and adds the user to the context
func AuthMiddleware(next http.Handler, jwtSecretBytes []byte) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		authHeader := r.Header.Get("Authorization")
		if authHeader == "" {
			next.ServeHTTP(w, r)
			return
		}

		tokenString := strings.Replace(authHeader, "Bearer ", "", 1)
		token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
			}
			return jwtSecretBytes, nil
		})

		if err != nil {
			log.Printf("Error parsing token: %v", err)
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusUnauthorized)
			json.NewEncoder(w).Encode(GraphQLResponse{
				Errors: []GraphQLResponseError{
					{
						Message: "Invalid or expired token",
						Extensions: map[string]interface{}{
							"code": "UNAUTHENTICATED",
						},
					},
				},
			})
			return
		}

		if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
			userID, ok := claims["userID"].(float64)
			if !ok {
				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusUnauthorized)
				json.NewEncoder(w).Encode(GraphQLResponse{
					Errors: []GraphQLResponseError{
						{
							Message: "Invalid token claims (userID missing or wrong type)",
							Extensions: map[string]interface{}{
								"code": "INVALID_TOKEN_CLAIMS",
							},
						},
					},
				})
				return
			}
			userName, ok := claims["name"].(string)
			if !ok {
				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusUnauthorized)
				json.NewEncoder(w).Encode(GraphQLResponse{
					Errors: []GraphQLResponseError{
						{
							Message: "Invalid token claims (name missing or wrong type)",
							Extensions: map[string]interface{}{
								"code": "INVALID_TOKEN_CLAIMS",
							},
						},
					},
				})
				return
			}
			userEmail, ok := claims["email"].(string)
			if !ok {
				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusUnauthorized)
				json.NewEncoder(w).Encode(GraphQLResponse{
					Errors: []GraphQLResponseError{
						{
							Message: "Invalid token claims (email missing or wrong type)",
							Extensions: map[string]interface{}{
								"code": "INVALID_TOKEN_CLAIMS",
							},
						},
					},
				})
				return
			}

			user := &model.User{
				ID:    int32(userID),
				Name:  userName,
				Email: userEmail,
			}
			ctx := context.WithValue(r.Context(), userCtxKey, user)
			r = r.WithContext(ctx)
		} else {
			log.Printf("Invalid token: %v", err)
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusUnauthorized)
			json.NewEncoder(w).Encode(GraphQLResponse{
				Errors: []GraphQLResponseError{
					{
						Message: "Invalid token",
						Extensions: map[string]interface{}{
							"code": "UNAUTHENTICATED",
						},
					},
				},
			})
			return
		}

		next.ServeHTTP(w, r)
	})
}

// GetAuthenticatedUserFromContext finds the user from the context.
func GetAuthenticatedUserFromContext(ctx context.Context) *model.User {
	raw, _ := ctx.Value(userCtxKey).(*model.User)
	return raw
}