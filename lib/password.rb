require 'bcrypt'

module Password
  def self.hashed(plaintext)
    BCrypt::Password.create(plaintext).to_s
  end

  def self.compare(plaintext, hash)
    plaintext && hash && BCrypt::Password.new(hash) == plaintext
  end
end
