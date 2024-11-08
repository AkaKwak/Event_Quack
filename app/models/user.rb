class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: { visitor: 0, author: 1 }
  has_many :events, foreign_key: 'user_id', class_name: 'Event', dependent: :destroy
  has_many :attendances
  has_many :attended_events, through: :attendances, source: :event
  has_one_attached :profile_picture

  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  def admin?
    is_admin
  end

  def author?
    role == 'author'
  end
end
