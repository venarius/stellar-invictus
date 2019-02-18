class User < ApplicationRecord
  
  acts_as_voter
  
  belongs_to :faction, optional: true
  belongs_to :system, optional: true
  belongs_to :location, optional: true
  belongs_to :fleet, optional: true
  belongs_to :corporation, optional: true
  
  has_many :chat_messages, dependent: :destroy
  has_many :spaceships, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :structures, dependent: :destroy
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships
  has_many :craft_jobs, dependent: :destroy
  has_many :missions, dependent: :destroy
  has_many :blueprints, dependent: :destroy
  has_many :market_listings, dependent: :destroy
  
  has_and_belongs_to_many :chat_rooms
  
  enum corporation_role: [:recruit, :lieutenant, :commodore, :admiral, :founder]
  
  delegate :name, :security_status, :to => :system, :prefix => true
  delegate :location_type, :enemy_amount, :to => :location, :prefix => true
  delegate :name, :to => :faction, :prefix => true
  delegate :name, :ticker, :to => :corporation, :prefix => true
  
  # Validations
  validates :name, :family_name, :avatar, presence: true
  validates :name, uniqueness: { scope: :family_name }
  validates :email, uniqueness: true
  validates_format_of :name, :family_name, :with => /\A[a-zA-Z]+\z/i, message: I18n.t('validations.can_only_contain_letters')
  validates :name, :family_name, length: { minimum: 2, maximum: 20,
            too_short: I18n.t('validations.too_short_2'), too_long: I18n.t('validations.too_long_name') }
            
  validate :check_avatar
  
  # Devise
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: %i[facebook]
  
  # Sets full name after create       
  after_create do
    self.update_columns(full_name: "#{name} #{family_name}".downcase.titleize)
  end
  
  # Verify Avatar
  def check_avatar
    unless %w(M_1 M_2 M_3 M_4 M_5 M_6 M_7 M_8 M_9 M_10 M_11 M_12 M_13 M_14 M_15 M_16 M_17
              F_1 F_2 F_3 F_4 F_5 F_6 F_7 F_8 F_9 F_10 F_11 F_12 F_13 F_14 F_15).include?(self.avatar)
      errors.add(:avatar, "has not a correct value")
    end
  end
  
  before_destroy do
    self.corporation.destroy if self.founder? and self.corporation # corporation
    Friendship.where(friend_id: self.id).destroy_all # friendships
    GameMail.where(sender_id: self.id).destroy_all # game mails
  end
  
  # Will be called when a user loggs in
  def appear
    AppearWorker.perform_async(self.id)
  end
  
  # Will be called when a user loggs off
  def disappear
    self.update_columns(target_id: nil) and DisappearWorker.perform_async(self.id)
  end
  
  # Gets active spaceship of user
  def active_spaceship
    Spaceship.find(self.active_spaceship_id) rescue nil
  end
  
  # Returns if player can be attacked
  def can_be_attacked
    !docked and !in_warp and online > 0 and (self.active_spaceship.hp rescue 0) > 0
  end
  
  # Returns target of player
  def target
    User.find(target_id) rescue nil if target_id?
  end
  
  # Returns mining target of player
  def mining_target
    Asteroid.find(mining_target_id) rescue nil if mining_target_id?
  end
  
  # Returns npc target of player
  def npc_target
    Npc.find(npc_target_id) rescue nil if npc_target_id?
  end
  
  # Lets the player die
  def die(police=false)
    # Get old System
    old_system = System.find(self.system_id)
    
    # Get ActionCable Server
    ac_server = ActionCable.server
    
    # Tell others in system that player "warped out"
    ac_server.broadcast("location_#{self.location.id}", method: 'player_warp_out', name: self.full_name)
    ac_server.broadcast("location_#{self.location.id}", method: 'log', text: I18n.t('log.got_killed', name: self.full_name) )
    
    # Create Wreck and fill with random loot
    self.active_spaceship.deactivate_equipment and self.active_spaceship.drop_loot if self.active_spaceship
    ac_server.broadcast("location_#{self.location.id}", method: 'player_appeared')
    
    # Destroy current spaceship of user and give him a nano if not insured
    old_ship = self.active_spaceship.destroy if self.active_spaceship
    if old_ship&.insured and !police
      spaceship = Spaceship.create(user_id: self.id, name: old_ship.name, hp: Spaceship.ship_variables[old_ship.name]['hp'])
      self.update_columns(active_spaceship_id: spaceship.id)
    else
      self.give_nano
    end
    
    # Make User docked at his factions station
    rand_location = self.faction.locations.where(location_type: :station).order(Arel.sql("RANDOM()")).first rescue nil
    self.update_columns(in_warp: false, docked: true, location_id: rand_location.id, system_id: rand_location.system.id, target_id: nil, mining_target_id: nil, npc_target_id: nil)
    
    # Tell user to reload page
    ac_server.broadcast("player_#{self.id}", method: 'reload_page')
    
    # Tell everyone in new system to update their local players
    old_system.update_local_players
    
    PlayerDiedWorker.perform_in(1.second, self.id)
  end
  
  # Returns if user is in same fleet with given id
  def in_same_fleet_as(id)
    f_id = self.fleet_id
    f_id != nil and f_id == User.find(id).fleet_id
  end
  
  # Returns if user is in same fleet with given id
  def in_same_corporation_as(id)
    f_id = self.corporation_id
    f_id != nil and f_id == User.find(id).corporation_id
  end
  
  # Gets the user remove being a target of other players
  def remove_being_targeted
    Npc.where(target: self.id).update_all(target: nil)
    User.where(target_id: self.id).each do |user|
      user.update_columns(target_id: nil)
      user.active_spaceship.deactivate_equipment if user.is_attacking
      ActionCable.server.broadcast("player_#{user.id}", method: 'remove_target')
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
    ship_vars = Spaceship.ship_variables[name]
    ship_vars and self.units >= ship_vars['price'] and self.location.get_ships_for_sale.has_key?(name)
  end
  
  # Reduce the user's units
  def reduce_units(amount)
    self.update_columns(units: self.reload.units - amount)
  end
  
  # Give the user units
  def give_units(amount)
    if self.corporation and self.corporation.tax > 0
      new_amount = amount - amount * (self.corporation.tax / 100)
      self.corporation.update_columns(units: self.corporation.units + (amount - new_amount))
      self.update_columns(units: self.reload.units + new_amount)
    else
      self.update_columns(units: self.reload.units + amount)
    end
  end
  
  # Give user a nano
  def give_nano
    spaceship = Spaceship.create(user_id: self.id, name: 'Nano', hp: 150)
    Item.create(loader: 'equipment.miner.basic_miner', spaceship: spaceship, equipped: true)
    Item.create(loader: 'equipment.weapons.laser_gatling', spaceship: spaceship, equipped: true)
    self.update_columns(active_spaceship_id: spaceship.id)
  end
  
  # Give bounty to player (50% share of loss)
  def give_bounty(player)
    if self.bounty > 0
      value = (self.active_spaceship.get_total_value * 0.5).round
      
      if value <= self.bounty
        self.update_columns(bounty: self.bounty - value)
      else
        value = self.bounty
        self.update_columns(bounty: 0)
      end
      
      player.update_columns(bounty_claimed: player.reload.bounty_claimed +  value)
      player.give_units(value)
      
      ActionCable.server.broadcast("player_#{player.id}", method: 'notify_alert', text: I18n.t('notification.received_bounty', user: self.full_name, amount: value))
      ActionCable.server.broadcast("player_#{player.id}", method: 'refresh_player_info')
    end
  end
  
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.skip_confirmation!
    end
  end
    
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
        user.password = Devise.friendly_token[0, 20]
        user.uid = session["devise.facebook_data"]["uid"]
        user.provider = session["devise.facebook_data"]["provider"]
        user.skip_confirmation!
      end
    end
  end
  
end
