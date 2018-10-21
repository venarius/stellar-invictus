class User < ApplicationRecord
  belongs_to :faction, optional: true
  
  
  validates :name, :family_name, :email, :password, :password_confirmation, 
            presence: true
            
  validates_format_of :name, :family_name, :with => /\A[a-zA-Z]+\z/i,
                      message: I18n.t('validations.can_only_contain_letters')
                      
  validates :name, :family_name, length: { minimum: 2, maximum: 20,
            too_short: I18n.t('validations.too_short'), too_long: I18n.t('validations.too_long') }
  
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable
end
