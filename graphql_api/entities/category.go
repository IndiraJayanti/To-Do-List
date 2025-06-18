package entities

type Category struct {
	ID        uint      `gorm:"primaryKey;autoIncrement;column:id"`
	Name      string    `gorm:"column:name"`
}

func (Category) TableName() string {
	return "category"
}