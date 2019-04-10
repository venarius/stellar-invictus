# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include Ensurance

  self.abstract_class = true

  def self.random_row
    # source: https://tableplus.io/blog/2018/08/postgresql-how-to-quickly-select-a-random-row-from-a-table.html
    self.offset((rand() * self.count).floor).limit(1).first
  end
end
