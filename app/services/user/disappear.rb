class User::Disappear < ApplicationService
  required :user, ensure: ::User

  def perform
  end

  private

end