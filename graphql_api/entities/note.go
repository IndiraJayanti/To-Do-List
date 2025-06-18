package entities

import "time"

type Note struct {
	ID           uint       `gorm:"primaryKey;autoIncrement;column:id"`
	Title        string     `gorm:"column:title"`
	Content      string     `gorm:"column:content"`
	IsFavorite   bool       `gorm:"column:is_favorite"`
	CreatedBy    uint       `gorm:"column:created_by"`
	IDCategory   uint       `gorm:"column:id_category"`
	CreatedAt    time.Time  `gorm:"column:created_at;autoCreateTime"`
	UpdatedAt    time.Time  `gorm:"column:updated_at;autoUpdateTime"`
	ReminderTime *time.Time `gorm:"column:reminder_time"`
	// Relasi: GORM akan mencari User dan Category secara otomatis
	User     *User     `gorm:"foreignKey:CreatedBy"`
	Category *Category `gorm:"foreignKey:IDCategory"`
}

func (Note) TableName() string {
	return "note"
}
