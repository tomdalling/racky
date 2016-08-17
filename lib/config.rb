require 'yaml'

class Config
  KEYS = %w(
    DB_CONNECTION_STR
  )

  MissingKey = Class.new(StandardError)

  KEYS.each { |k| attr_reader(k.downcase) }

  def initialize(hash)
    KEYS.each do |k|
      raise MissingKey, k.inspect unless hash.has_key?(k)
      instance_variable_set('@'+k.downcase, hash.fetch(k))
    end
  end

  def self.from_file(path)
    new(YAML.load(File.read(path)))
  end
end
