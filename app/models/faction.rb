class Faction < ApplicationRecord
  has_many :users
  has_one :location
end
