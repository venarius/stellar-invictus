class Mission < ApplicationRecord
  belongs_to :faction
  belongs_to :user
  
  has_one :location, dependent: :destroy
  has_many :items, dependent: :destroy
  
  enum mission_type: [:tutorial, :delivery, :combat, :mining, :market]
  enum mission_status: [:offered, :active, :failed, :completed]
  enum difficulty: [:easy, :medium, :hard]
end
