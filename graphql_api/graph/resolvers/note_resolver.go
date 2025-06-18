package resolvers

import (
	"context"
	"fmt"
	"graphql_api/graph/model"
	"graphql_api/services"
	"strconv"
	"time" // Import time
)

type NoteMutationResolver struct {
	noteService *services.NoteService
}

type NoteQueryResolver struct {
	noteService *services.NoteService
}

func NewNoteMutationResolver(noteService *services.NoteService) *NoteMutationResolver {
	return &NoteMutationResolver{noteService: noteService}
}

func NewNoteQueryResolver(noteService *services.NoteService) *NoteQueryResolver {
	return &NoteQueryResolver{noteService: noteService}
}

// PERBAIKI: Tambahkan `reminderTime *string` sebagai parameter.
func (r *NoteMutationResolver) CreateNote(ctx context.Context, title string, content string, isFavorite bool, createdBy string, idCategory string, reminderTime *string) (*model.Note, error) {
	parsedCreatedBy, err := strconv.ParseUint(createdBy, 10, 32)
	if err != nil {
		return nil, fmt.Errorf("invalid createdBy ID: %w", err)
	}
	parsedIDCategory, err := strconv.ParseUint(idCategory, 10, 32)
	if err != nil {
		return nil, fmt.Errorf("invalid idCategory ID: %w", err)
	}

	var parsedReminderTime *time.Time
	if reminderTime != nil && *reminderTime != "" {
		// Gunakan time.RFC3339Nano untuk parsing string ISO 8601 dengan Z (UTC)
		t, err := time.Parse(time.RFC3339Nano, *reminderTime)
		if err != nil {
			return nil, fmt.Errorf("invalid reminder time format: %w", err)
		}
		parsedReminderTime = &t
	}

	// Teruskan `parsedReminderTime` ke service
	noteEntity, err := r.noteService.CreateNote(title, content, isFavorite, uint(parsedCreatedBy), uint(parsedIDCategory), parsedReminderTime)
	if err != nil {
		return nil, err
	}

	return MapNoteEntityToModel(noteEntity), nil
}

// PERBAIKI: Tambahkan `reminderTime *string` sebagai parameter.
func (r *NoteMutationResolver) UpdateNote(ctx context.Context, id int32, title *string, content *string, isFavorite *bool, idCategory *string, reminderTime *string) (*model.Note, error) {
	updates := make(map[string]interface{})
	if title != nil {
		updates["title"] = *title
	}
	if content != nil {
		updates["content"] = *content
	}
	if isFavorite != nil {
		updates["is_favorite"] = *isFavorite
	}
	if idCategory != nil {
		parsedIDCategory, err := strconv.ParseUint(*idCategory, 10, 32)
		if err != nil {
			return nil, fmt.Errorf("invalid idCategory ID: %w", err)
		}
		updates["id_category"] = uint(parsedIDCategory)
	}
	// Tambahkan penanganan reminderTime
	if reminderTime != nil {
		if *reminderTime != "" {
			// Gunakan time.RFC3339Nano untuk parsing string ISO 8601 dengan Z (UTC)
			t, err := time.Parse(time.RFC3339Nano, *reminderTime)
			if err != nil {
				return nil, fmt.Errorf("invalid reminder time format: %w", err)
			}
			updates["reminder_time"] = t
		} else {
			updates["reminder_time"] = nil
		}
	} else {
		updates["reminder_time"] = nil
	}

	noteEntity, err := r.noteService.UpdateNote(uint(id), updates)
	if err != nil {
		return nil, err
	}
	if noteEntity == nil {
		return nil, nil
	}

	return MapNoteEntityToModel(noteEntity), nil
}

func (r *NoteMutationResolver) DeleteNote(ctx context.Context, id int32) (bool, error) {
	return r.noteService.DeleteNote(uint(id))
}

func (r *NoteQueryResolver) Notes(ctx context.Context, getCurrentUserFunc func(context.Context) *model.User) ([]*model.Note, error) {
	currentUser := getCurrentUserFunc(ctx)
	if currentUser == nil {
		return nil, fmt.Errorf("access denied: user not authenticated")
	}

	noteEntities, err := r.noteService.GetAllNotesByUserID(uint(currentUser.ID))
	if err != nil {
		return nil, err
	}

	var notes []*model.Note
	for _, ne := range noteEntities {
		notes = append(notes, MapNoteEntityToModel(ne))
	}
	return notes, nil
}

func (r *NoteQueryResolver) NotesByCategory(ctx context.Context, idCategory string, getCurrentUserFunc func(context.Context) *model.User) ([]*model.Note, error) {
	currentUser := getCurrentUserFunc(ctx)
	if currentUser == nil {
		return nil, fmt.Errorf("access denied: user not authenticated")
	}

	parsedIDCategory, err := strconv.ParseUint(idCategory, 10, 32)
	if err != nil {
		return nil, fmt.Errorf("invalid idCategory ID: %w", err)
	}

	noteEntities, err := r.noteService.GetNotesByCategoryIDAndUserID(uint(parsedIDCategory), uint(currentUser.ID))
	if err != nil {
		return nil, err
	}

	var notes []*model.Note
	for _, ne := range noteEntities {
		notes = append(notes, MapNoteEntityToModel(ne))
	}
	return notes, nil
}

func (r *NoteQueryResolver) FavoriteNotes(ctx context.Context, getCurrentUserFunc func(context.Context) *model.User) ([]*model.Note, error) {
	currentUser := getCurrentUserFunc(ctx)
	if currentUser == nil {
		return nil, fmt.Errorf("access denied: user not authenticated")
	}

	noteEntities, err := r.noteService.GetFavoriteNotesByUserID(uint(currentUser.ID))
	if err != nil {
		return nil, err
	}

	var notes []*model.Note
	for _, ne := range noteEntities {
		notes = append(notes, MapNoteEntityToModel(ne))
	}
	return notes, nil
}
