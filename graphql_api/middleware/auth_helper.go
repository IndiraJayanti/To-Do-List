// graphql_api/middleware/auth_helper.go
package middleware

import (
	"graphql_api/graph/model"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

// GenerateToken is a helper function to create a JWT for a given user.
func GenerateToken(user *model.User, jwtSecret string) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"userID": user.ID,
		"name":   user.Name,
		"email":  user.Email,
		"exp":    time.Now().Add(time.Hour * 24).Unix(), // Token berlaku selama 24 jam
	})

	tokenString, err := token.SignedString([]byte(jwtSecret))
	if err != nil {
		return "", err
	}
	return tokenString, nil
}