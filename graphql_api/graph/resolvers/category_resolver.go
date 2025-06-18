package resolvers

import (
	"context"
	"graphql_api/graph/model"
	"graphql_api/services"
)


type CategoryQueryResolver struct {
	categoryService *services.CategoryService
}


func NewCategoryQueryResolver(categoryService *services.CategoryService) *CategoryQueryResolver {
	return &CategoryQueryResolver{categoryService: categoryService}
}

func (r *CategoryQueryResolver) Categories(ctx context.Context) ([]*model.Category, error) {
	categoryEntities, err := r.categoryService.GetAllCategories()
	if err != nil {
		return nil, err
	}
	var categories []*model.Category
	for _, ce := range categoryEntities {
		categories = append(categories, MapCategoryEntityToModel(ce))
	}
	return categories, nil
}

func (r *CategoryQueryResolver) Category(ctx context.Context, id int32) (*model.Category, error) {
	categoryEntity, err := r.categoryService.GetCategoryByID(uint(id))
	if err != nil {
		return nil, err
	}
	if categoryEntity == nil {
		return nil, nil
	}
	return MapCategoryEntityToModel(categoryEntity), nil
}