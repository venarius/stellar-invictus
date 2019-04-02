class RandService
  ALPHA_CHARSET = Array('A'..'Z') + Array('a'..'z')
  UPCASE_ALHPA_CHARSET = Array('A'..'Z')

  def self.upcase_alpha(size)
    Array.new(size) { UPCASE_ALHPA_CHARSET.sample }.join
  end

  def self.alpha(size)
    Array.new(size) { ALHPA_CHARSET.sample }.join
  end
end