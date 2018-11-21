class User < ApplicationRecord
  
  belongs_to :faction, optional: true
  belongs_to :system, optional: true
  belongs_to :location, optional: true
  belongs_to :fleet, optional: true
  
  has_many :chat_messages, dependent: :destroy
  has_many :spaceships, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :structures, dependent: :destroy
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships
  
  has_and_belongs_to_many :chat_rooms
  
  # Validations
  validates :name, :family_name, :email, :password, :password_confirmation, :avatar, presence: true
  validates :name, uniqueness: { scope: :family_name }
  validates :email, uniqueness: true
  validates_format_of :name, :family_name, :with => /\A[a-zA-Z]+\z/i, message: I18n.t('validations.can_only_contain_letters')
  validates :name, :family_name, length: { minimum: 2, maximum: 20,
            too_short: I18n.t('validations.too_short'), too_long: I18n.t('validations.too_long_name') }
  
  # Devise
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable
  
  # Sets full name after create       
  after_create do
    self.update_columns(full_name: "#{name} #{family_name}")
  end
  
  # Will be called when a user loggs in
  def appear
    AppearWorker.perform_async(self.id)
  end
  
  # Will be called when a user loggs off
  def disappear
    self.update_columns(target_id: nil)
    DisappearWorker.perform_async(self.id)
  end
  
  # Gets active spaceship of user
  def active_spaceship
    Spaceship.find(self.active_spaceship_id) rescue nil
  end
  
  # Returns if player can be attacked
  def can_be_attacked
    ship_hp = active_spaceship.hp rescue 0
    !docked and !in_warp and online > 0 and ship_hp > 0
  end
  
  # Returns target of player
  def target
    User.find(target_id) rescue nil if target_id?
  end
  
  # Returns mining target of player
  def mining_target
    Asteroid.find(mining_target_id) if mining_target_id?
  end
  
  # Returns npc target of player
  def npc_target
    Npc.find(npc_target_id) if npc_target_id?
  end
  
  # Lets the player die
  def die
    PlayerDiedWorker.perform_async(self.id)
  end
  
  # Returns if user is in same fleet with given id
  def in_same_fleet_as(id)
    f_id = self.fleet_id
    f_id != nil and f_id == User.find(id).fleet_id
  end
  
  # Gets the user remove being a target of other players
  def remove_being_targeted
    User.where(target_id: self.id).each do |user|
      user.update_columns(target_id: nil)
      ActionCable.server.broadcast("player_#{user.id}", method: 'refresh_target_info')
    end
  end
  
  # Docks the player
  def dock
    self.update_columns(docked: true, target_id: nil)
    ActionCable.server.broadcast("location_#{self.location.id}", method: 'player_warp_out', name: self.full_name)
    remove_being_targeted
  end
  
  # Undocks the player
  def undock
    if self.docked
      self.update_columns(docked: false)
      ActionCable.server.broadcast("location_#{self.location.id}", method: 'player_appeared')
    end
  end
  
  # Returns if player can buy a ship
  def can_buy_ship(name)
    ship_vars = SHIP_VARIABLES[name]
    ship_vars and self.units >= ship_vars['price'] and self.location.get_ships_for_sale.has_key?(name)
  end
  
  # Reduce the user's units
  def reduce_units(amount)
    self.update_columns(units: self.units - amount)
  end
end
