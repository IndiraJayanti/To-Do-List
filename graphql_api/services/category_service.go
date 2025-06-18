package services

import (
	"graphql_api/entities"
	"gorm.io/gorm"
)

type CategoryService struct {
	DB *gorm.DB
}

func NewCategoryService(db *gorm.DB) *CategoryService {
	return &CategoryService{DB: db}
}

func (s *CategoryService) GetCategoryByID(id uint) (*entities.Category, error) {
	var category entities.Category
	if err := s.DB.First(&category, id).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, nil
		}
		return nil, err
	}
	return &category, nil
}

func (s *CategoryService) GetAllCategories() ([]*entities.Category, error) {
	var categories []*entities.Category
	if err := s.DB.Find(&categories).Error; err != nil {
		return nil, err
	}
	return categories, nil
}