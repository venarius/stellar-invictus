class InvalidRequest < StandardError; end

class RedirectRequest < StandardError
  attr_reader :error

  def initialize(route, error: nil)
    @error = error
    super(route)
  end
  alias route message
end
