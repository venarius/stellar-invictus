class FinanceHistory < ApplicationRecord
  belongs_to :user
  belongs_to :corporation
  
  enum action: [:deposit, :withdraw]
end
