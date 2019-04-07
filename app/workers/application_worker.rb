class ApplicationWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def debug_args(method = :perform, **kwargs)
    # Comment this line out for debugging info on workers
    return

    mapped = kwargs.map { |k, v| "#{k}: #{v.nil? ? 'nil' : v}" }
    output = +"#{self.class}"
    output << ".#{method}" if method
    output << "(#{mapped.join(', ')})"
    ap output
  end
end
