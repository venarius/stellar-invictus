# Shoulda
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    # Choose a test framework:
    with.test_framework :rspec

    # Or, choose all of the above:
    with.library :rails
  end
end
