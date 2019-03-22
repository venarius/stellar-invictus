require 'single_sign_on'

class DiscourseSsoController < ApplicationController

  def sso
    secret = "B0cqKNtjhlXrS2J2BAB1gyIg5tjMUZwfdBfrScubAbYsOV1Zd1CisMD3dVXVScXmR5HZtuafJvn10kcC62JyNVC5bmBSGUzl2w0FfViY9tk63mtyCGsZZiTE29iRRm4C"
    sso = SingleSignOn.parse(request.query_string, secret)
    sso.email = current_user.email # from devise
    sso.name = current_user.full_name # this is a custom method on the User class
    sso.username = current_user.full_name.titleize.gsub(' ', '_') # from devise
    sso.external_id = current_user.id # from devise
    sso.avatar_url = "https://s3-eu-west-1.amazonaws.com/static.stellar-invictus.com/assets/avatars/#{current_user.avatar}.jpg"
    sso.sso_secret = secret

    redirect_to sso.to_url("https://forums.stellar-invictus.com/session/sso_login")
  end

end
