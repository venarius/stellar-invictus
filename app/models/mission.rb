class Mission < ApplicationRecord
  belongs_to :faction
  belongs_to :user, optional: true
  belongs_to :location
  
  before_destroy do
    location.mission_location.destroy if location.mission_location
  end
  
  has_many :items, dependent: :destroy
  has_one  :mission_location, :class_name => "Location", dependent: :destroy
  
  enum mission_type: [:tutorial, :delivery, :combat, :mining, :market, :vip]
  enum mission_status: [:offered, :active, :failed, :completed]
  enum difficulty: [:easy, :medium, :hard]
  
  delegate :reputation_1, :reputation_2, :reputation_3, :to => :user, :prefix => true
  delegate :name, :to => :faction, :prefix => true
end
