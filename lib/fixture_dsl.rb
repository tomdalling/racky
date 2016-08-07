require 'lif'
require 'password'

class FixtureDSL
  attr_reader :records_by_table

  def initialize
    @records_by_table = {}
    @plurals = {}
  end

  def def_tables(plurals)
    @plurals.merge!(plurals)
  end

  def lif_json(filename)
    path = "test/fixtures/#{filename}"
    doc = LIF::DocxParser.parse(path)
    LIF::JSON::Converter.convert(doc)
  end

  def password_hash(password)
    Password.hashed(password)
  end

  def method_missing(sym, *args, &block)
    table = pluralize(sym)
    records = (@records_by_table[table] ||= [])
    records << args.first
  end

  private

  def pluralize(word)
    @plurals.fetch(word) do
      "#{word}s".to_sym
    end
  end

end
