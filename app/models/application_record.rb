class ApplicationRecord < ActiveRecord::Base
  include Ensurance

  self.abstract_class = true
end
