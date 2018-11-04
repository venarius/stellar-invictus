class User < ApplicationRecord
  belongs_to :faction, optional: true
  belongs_to :system, optional: true
  belongs_to :location, optional: true
  has_many :chat_messages, dependent: :destroy
  has_many :spaceships, dependent: :destroy
  
  
  validates :name, :family_name, :email, :password, :password_confirmation, :avatar,
            presence: true
            
  validates :name, uniqueness: { scope: :family_name }
            
  validates :email, uniqueness: true
            
  validates_format_of :name, :family_name, :with => /\A[a-zA-Z]+\z/i,
                      message: I18n.t('validations.can_only_contain_letters')
                      
  validates :name, :family_name, length: { minimum: 2, maximum: 20,
            too_short: I18n.t('validations.too_short'), too_long: I18n.t('validations.too_long_name') }
  
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable
         
  after_create do
    self.update_columns(full_name: "#{name} #{family_name}")
  end
         
  def appear
    AppearWorker.perform_async(self.id)
  end
  
  def disappear
    self.update_columns(target_id: nil)
    DisappearWorker.perform_async(self.id)
  end
  
  def active_spaceship
    Spaceship.find(self.active_spaceship_id) rescue nil
  end
  
  def can_be_attacked
    !docked and !in_warp and online > 0
  end
  
  def target
    User.find(target_id) if target_id
  end
  
  def die
    PlayerDiedWorker.perform_async(self.id)
  end
end
