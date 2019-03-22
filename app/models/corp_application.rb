class CorpApplication < ApplicationRecord
  belongs_to :user
  belongs_to :corporation

  delegate :full_name, to: :user, prefix: true
end
