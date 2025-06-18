package graph

import (
	"context"
	"graphql_api/graph/model"
	"graphql_api/services" // Import services

	"gorm.io/gorm"
)

// This file will not be regenerated automatically.
//
// It serves as dependency injection for your app, add any dependencies you require here.

type Resolver struct {
	DB             *gorm.DB
	JWTSecret      string // Tambahkan field untuk secret key JWT
	ForContextFunc func(context.Context) *model.User
	NoteService    *services.NoteService
	UserService    *services.UserService
	CategoryService *services.CategoryService

}
