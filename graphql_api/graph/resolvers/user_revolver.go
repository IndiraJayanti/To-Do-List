package resolvers

import (
	"context"
	"fmt"
	"graphql_api/graph/model"
	"graphql_api/services"
	"golang.org/x/crypto/bcrypt"
)

type UserMutationResolver struct { // Diubah menjadi huruf kapital
	userService *services.UserService
	generateToken func(user *model.User) (string, error)
}

type UserQueryResolver struct { // Diubah menjadi huruf kapital
	userService *services.UserService
}

func NewUserMutationResolver(userService *services.UserService, generateToken func(user *model.User) (string, error)) *UserMutationResolver { // Ubah tipe kembalian
	return &UserMutationResolver{userService: userService, generateToken: generateToken}
}

func NewUserQueryResolver(userService *services.UserService) *UserQueryResolver { // Ubah tipe kembalian
	return &UserQueryResolver{userService: userService}
}

func (r *UserMutationResolver) CreateUser(ctx context.Context, name string, email string, password string) (*model.User, error) {
	userEntity, err := r.userService.CreateUser(name, email, password)
	if err != nil {
		return nil, err
	}
	return MapUserEntityToModel(userEntity), nil
}

func (r *UserMutationResolver) UpdateUser(ctx context.Context, id int32, name *string, email *string, password *string) (*model.User, error) {
	updates := make(map[string]interface{})
	if name != nil {
		updates["name"] = *name
	}
	if email != nil {
		updates["email"] = *email
	}
	if password != nil {
		updates["password"] = *password
	}

	userEntity, err := r.userService.UpdateUser(uint(id), updates)
	if err != nil {
		return nil, err
	}
	if userEntity == nil {
		return nil, nil
	}
	return MapUserEntityToModel(userEntity), nil
}

func (r *UserMutationResolver) DeleteUser(ctx context.Context, id int32) (bool, error) {
	return r.userService.DeleteUser(uint(id))
}

func (r *UserMutationResolver) Register(ctx context.Context, name string, email string, password string) (*model.AuthResponse, error) {
	userEntity, err := r.userService.CreateUser(name, email, password)
	if err != nil {
		return nil, fmt.Errorf("could not create user: %w", err)
	}

	userModel := MapUserEntityToModel(userEntity)

	token, err := r.generateToken(userModel)
	if err != nil {
		return nil, fmt.Errorf("could not generate token: %w", err)
	}

	return &model.AuthResponse{Token: token, User: userModel}, nil
}

func (r *UserMutationResolver) Login(ctx context.Context, email string, password string) (*model.AuthResponse, error) {
	userEntity, err := r.userService.GetUserByEmail(email)
	if err != nil {
		return nil, err
	}
	if userEntity == nil {
		return nil, fmt.Errorf("user not found")
	}

	err = bcrypt.CompareHashAndPassword([]byte(userEntity.Password), []byte(password))
	if err != nil {
		return nil, fmt.Errorf("invalid credentials")
	}

	userModel := MapUserEntityToModel(userEntity)

	token, err := r.generateToken(userModel)
	if err != nil {
		return nil, fmt.Errorf("could not generate token: %w", err)
	}

	return &model.AuthResponse{Token: token, User: userModel}, nil
}


func (r *UserQueryResolver) Users(ctx context.Context) ([]*model.User, error) {
	userEntities, err := r.userService.GetAllUsers()
	if err != nil {
		return nil, err
	}
	var users []*model.User
	for _, ue := range userEntities {
		users = append(users, MapUserEntityToModel(ue))
	}
	return users, nil
}

func (r *UserQueryResolver) User(ctx context.Context, id int32) (*model.User, error) {
	userEntity, err := r.userService.GetUserByID(uint(id))
	if err != nil {
		return nil, err
	}
	if userEntity == nil {
		return nil, nil
	}
	return MapUserEntityToModel(userEntity), nil
}