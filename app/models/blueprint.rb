# == Schema Information
#
# Table name: blueprints
#
#  id         :bigint(8)        not null, primary key
#  efficiency :float            default(1.5)
#  loader     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint(8)
#
# Indexes
#
#  index_blueprints_on_loader   (loader)
#  index_blueprints_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Blueprint < ApplicationRecord
  belongs_to :user
end
