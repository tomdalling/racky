#TODO: make this threadsafe
class Container
  KeyNotFound = Class.new(StandardError)
  DuplicateKey = Class.new(StandardError)
  CyclicDependencies = Class.new(StandardError)

  DEFAULT_OPTIONS = {
    memoize: true,
  }

  def initialize
    @registry = {}
    @memos = {}
    @resolve_stack = []
  end

  def register(key, options = {}, &creation_proc)
    if creation_proc.nil?
      raise ArgumentError, "Must provide a block to #register"
    end

    if @registry.has_key?(key)
      raise DuplicateKey, "Container already has a value registered for key: #{key.inspect}"
    end

    options = Options.new(DEFAULT_OPTIONS.merge(options))
    @registry[key] = Item.new(creation_proc, options)
  end

  def resolve(key)
    return @memos[key] if @memos.has_key?(key)

    if @resolve_stack.include?(key)
      cycle = @resolve_stack + [key]
      raise CyclicDependencies, "Found cyclic dependencies: #{cycle.map(&:inspect).join(' -> ')}"
    end

    item = @registry.fetch(key) do
      raise KeyNotFound, "Key not found in container: #{key.inspect}"
    end

    @resolve_stack.push(key)
    obj = begin
      item.creation_proc.call(self)
    ensure
      @resolve_stack.pop
      nil
    end

    @memos[key] = obj if item.options.memoize

    obj
  end
  alias_method :[], :resolve

  private

    Item = Struct.new(:creation_proc, :options)

    Options = Struct.new(*DEFAULT_OPTIONS.keys) do
      def initialize(attrs)
        bad_keys = attrs.keys.reject{ |k| DEFAULT_OPTIONS.has_key?(k) }
        unless bad_keys.empty?
          raise ArgumentError, "Unrecognised option(s): #{bad_keys.map(&:inspect).join(', ')}"
        end
        super(*attrs.values_at(*DEFAULT_OPTIONS.keys))
      end
    end
end
