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

// MapNoteEntityToModel mengkonversi entities.Note ke model.Note
func MapNoteEntityToModel(noteEntity *entities.Note) *model.Note {
	if noteEntity == nil {
		return nil
	}
	var reminderTimeStr *string
	if noteEntity.ReminderTime != nil {
		formattedTime := noteEntity.ReminderTime.Format(time.RFC3339Nano)
		reminderTimeStr = &formattedTime
	}

	return &model.Note{
		ID:           int32(noteEntity.ID),
		Title:        noteEntity.Title,
		Content:      noteEntity.Content,
		IsFavorite:   noteEntity.IsFavorite,
		CreatedBy:    int32(noteEntity.CreatedBy),
		IDCategory:   int32(noteEntity.IDCategory),
		CreatedAt:    noteEntity.CreatedAt.Format(time.RFC3339Nano),
		UpdatedAt:    noteEntity.UpdatedAt.Format(time.RFC3339Nano),
		ReminderTime: reminderTimeStr, // Tambahkan ini
		User:         MapUserEntityToModel(noteEntity.User),
		Category:     MapCategoryEntityToModel(noteEntity.Category),
	}
}
