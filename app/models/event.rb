class Event < ApplicationRecord
  belongs_to :user
  has_many :attendances
  has_many :users, through: :attendances

  validates :title, presence: true
  validates :description, presence: true
  validates :location, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :start_date, presence: true
  validates :duration, numericality: { only_integer: true, greater_than: 0 }
  validates :end_date, presence: true

  # Callback pour calculer end_date avant la sauvegarde
  before_validation :set_end_date
  
  def is_free?
    price == 0
  end
  
  private

  def set_end_date
    if start_date.present? && duration.present?
      self.end_date = start_date + duration.minutes
    end
  end
end
