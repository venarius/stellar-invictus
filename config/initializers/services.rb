# Define a dispatcher for `:model` option
rails_dispatcher = ->(ensure: nil, **options) do
  # NOTE: This is because 'ensure' is a reserved word in Ruby
  klass = binding.local_variable_get(:ensure)
  return options unless klass

  begin
    klass = klass.constantize if klass.is_a?(String)
  rescue NameError => e
    msg = "ApplicationService: #{self.class} cannot ensure(#{klass}) as the model can't be found"
    Rails.logger.error msg
    puts msg if !Rails.env.production?
    raise e
  end
  klass = klass.klass if klass.is_a?(ActiveRecord::Relation)

  coercer = ->(value) { klass.ensure(value) }
  options.merge(type: coercer)
end

# Register a dispatcher
Dry::Initializer::Dispatchers << rails_dispatcher
