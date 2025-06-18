package entities

import "time"

type User struct {
	ID        uint      `gorm:"primaryKey;autoIncrement;column:id"`
	Name      string    `gorm:"column:name"`
	Email     string    `gorm:"unique;column:email"`
	Password  string    `gorm:"column:password"`
	CreatedAt time.Time `gorm:"column:created_at;autoCreateTime"`
	UpdatedAt time.Time `gorm:"column:updated_at;autoUpdateTime"`
}

func (User) TableName() string {
	return "user"
}