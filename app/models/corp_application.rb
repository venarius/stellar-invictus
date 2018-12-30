class CorpApplication < ApplicationRecord
  belongs_to :user
  belongs_to :corporation
end
