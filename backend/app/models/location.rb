class Location < ApplicationRecord
  has_many :employees, dependent: :restrict_with_error

  validates :city, presence: true
  validates :country, presence: true
  validates :office_name, presence: true

  def display_name
    "#{office_name} (#{city}, #{country})"
  end
end
