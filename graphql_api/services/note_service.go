package services

import (
	"fmt"
	"gorm.io/gorm"
	"graphql_api/entities"
	"time"
)

type NoteService struct {
	DB *gorm.DB
}

func NewNoteService(db *gorm.DB) *NoteService {
	return &NoteService{DB: db}
}

// Tambahkan parameter reminderTime *time.Time
func (s *NoteService) CreateNote(title, content string, isFavorite bool, createdBy, idCategory uint, reminderTime *time.Time) (*entities.Note, error) {
	note := entities.Note{
		Title:        title,
		Content:      content,
		IsFavorite:   isFavorite,
		CreatedBy:    createdBy,
		IDCategory:   idCategory,
		CreatedAt:    time.Now(),
		UpdatedAt:    time.Now(),
		ReminderTime: reminderTime, // Simpan waktu pengingat
	}
	if err := s.DB.Create(&note).Error; err != nil {
		return nil, fmt.Errorf("failed to create note: %w", err)
	}
	// Muat User dan Category setelah membuat, agar relasi terisi
	if err := s.DB.Preload("User").Preload("Category").First(&note, note.ID).Error; err != nil {
		return nil, fmt.Errorf("failed to retrieve created note with relations: %w", err)
	}
	return &note, nil
}

func (s *NoteService) GetNoteByID(id uint) (*entities.Note, error) {
	var note entities.Note
	if err := s.DB.Preload("User").Preload("Category").First(&note, id).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, nil
		}
		return nil, err
	}
	return &note, nil
}

func (s *NoteService) UpdateNote(id uint, updates map[string]interface{}) (*entities.Note, error) {
	var note entities.Note
	if err := s.DB.First(&note, id).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, nil
		}
		return nil, err
	}

	// Tangani reminder_time jika ada di updates
	if rt, ok := updates["reminder_time"]; ok {
		if rt != nil { // Pastikan bukan nil sebelum mencoba konversi
			if t, isTime := rt.(time.Time); isTime { // Cek apakah sudah time.Time
				note.ReminderTime = &t
			} else {
				return nil, fmt.Errorf("unexpected type for reminder_time in updates")
			}
		} else {
			note.ReminderTime = nil
		}
		delete(updates, "reminder_time")
	}
	// Pastikan updated_at selalu di-set
	updates["updated_at"] = time.Now()

	if err := s.DB.Model(&note).Updates(updates).Error; err != nil {
		return nil, err
	}
	if err := s.DB.Save(&note).Error; err != nil {
		return nil, err
	}
	if err := s.DB.Preload("User").Preload("Category").First(&note, note.ID).Error; err != nil {
		return nil, fmt.Errorf("failed to retrieve updated note with relations: %w", err)
	}
	return &note, nil
}

func (s *NoteService) DeleteNote(id uint) (bool, error) {
	result := s.DB.Delete(&entities.Note{}, id)
	return result.RowsAffected > 0, result.Error
}

func (s *NoteService) GetAllNotesByUserID(userID uint) ([]*entities.Note, error) {
	var notes []*entities.Note
	if err := s.DB.Preload("User").Preload("Category").Where("created_by = ?", userID).Find(&notes).Error; err != nil {
		return nil, err
	}
	return notes, nil
}

func (s *NoteService) GetNotesByCategoryIDAndUserID(categoryID, userID uint) ([]*entities.Note, error) {
	var notes []*entities.Note
	if err := s.DB.Preload("User").Preload("Category").Where("id_category = ? AND created_by = ?", categoryID, userID).Find(&notes).Error; err != nil {
		return nil, err
	}
	return notes, nil
}

func (s *NoteService) GetFavoriteNotesByUserID(userID uint) ([]*entities.Note, error) {
	var notes []*entities.Note
	if err := s.DB.Preload("User").Preload("Category").Where("is_favorite = ? AND created_by = ?", true, userID).Find(&notes).Error; err != nil {
		return nil, err
	}
	return notes, nil
}
