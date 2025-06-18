package services

import (
	"graphql_api/entities"
	"gorm.io/gorm"
	"golang.org/x/crypto/bcrypt"
	"fmt"
)

type UserService struct {
	DB *gorm.DB
}

func NewUserService(db *gorm.DB) *UserService {
	return &UserService{DB: db}
}

func (s *UserService) CreateUser(name, email, password string) (*entities.User, error) {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return nil, fmt.Errorf("could not hash password: %w", err)
	}

	user := entities.User{
		Name:     name,
		Email:    email,
		Password: string(hashedPassword),
	}

	if err := s.DB.Create(&user).Error; err != nil {
		return nil, err
	}
	return &user, nil
}

func (s *UserService) GetUserByID(id uint) (*entities.User, error) {
	var user entities.User
	if err := s.DB.First(&user, id).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, nil
		}
		return nil, err
	}
	return &user, nil
}

func (s *UserService) GetUserByEmail(email string) (*entities.User, error) {
	var user entities.User
	if err := s.DB.Where("email = ?", email).First(&user).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, nil
		}
		return nil, err
	}
	return &user, nil
}

func (s *UserService) UpdateUser(id uint, updates map[string]interface{}) (*entities.User, error) {
	var user entities.User
	if err := s.DB.First(&user, id).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, nil
		}
		return nil, err
	}

	if pwd, ok := updates["password"].(string); ok && pwd != "" {
		hashedPassword, err := bcrypt.GenerateFromPassword([]byte(pwd), bcrypt.DefaultCost)
		if err != nil {
			return nil, fmt.Errorf("could not hash new password: %w", err)
		}
		updates["password"] = string(hashedPassword)
	}

	if err := s.DB.Model(&user).Updates(updates).Error; err != nil {
		return nil, err
	}
	// Ambil kembali user yang sudah diupdate untuk memastikan semua field terbaru terisi
	if err := s.DB.First(&user, id).Error; err != nil {
		return nil, err
	}
	return &user, nil
}


func (s *UserService) DeleteUser(id uint) (bool, error) {
	result := s.DB.Delete(&entities.User{}, id)
	return result.RowsAffected > 0, result.Error
}

func (s *UserService) GetAllUsers() ([]*entities.User, error) {
	var users []*entities.User
	if err := s.DB.Find(&users).Error; err != nil {
		return nil, err
	}
	return users, nil
}