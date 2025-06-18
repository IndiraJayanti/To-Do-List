package resolvers

import (
	"graphql_api/entities"
	"graphql_api/graph/model"
)

// MapUserEntityToModel mengkonversi entities.User ke model.User
func MapUserEntityToModel(userEntity *entities.User) *model.User {
	if userEntity == nil {
		return nil
	}
	return &model.User{
		ID:    int32(userEntity.ID),
		Name:  userEntity.Name,
		Email: userEntity.Email,
	}
}
