module WorkETag
  def self.generate(*works)
    Digest::MD5.hexdigest(multi(works))
  end

  def self.multi(works)
    works.map(&method(:single)).join(',')
  end

  def self.single(work)
    if work
      # TODO: don't use published_at. Use updated_at or something.
      parts = []
      parts << work[:id]
      parts << work[:published_at].iso8601
      parts.join('-')
    else
      'nil'
    end
  end
end
