class User < ApplicationRecord
  has_many :events, foreign_key: 'user_id', class_name: 'Event', dependent: :destroy
  has_many :attendances
  has_many :attended_events, through: :attendances, source: :event

  validates :email, presence: true, uniqueness: true
  validates :first_name, :last_name, presence: true
end
