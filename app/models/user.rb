class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :events, foreign_key: 'user_id', class_name: 'Event', dependent: :destroy
  has_many :attendances
  has_many :attended_events, through: :attendances, source: :event

  validates :email, presence: true, uniqueness: true
end
