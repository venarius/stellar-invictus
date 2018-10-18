class User < ApplicationRecord
  belongs_to :faction, optional: true
  
  
  validates :name, :family_name, :email, :password, :password_confirmation, 
            presence: true
            
  validates_format_of :name, :family_name, :with => /\A[a-zA-Z]+\z/i,
                      message: I18n.t('can_only_contain_letters_dic')
  
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable
end
