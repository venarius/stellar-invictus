class FinanceHistory < ApplicationRecord
  belongs_to :user
  belongs_to :corporation
  
  enum action: [:deposit, :withdraw]
  
  delegate :full_name, :to => :user, :prefix => true
end
