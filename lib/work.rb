module Work
  def self.machine_name(title)
    title.gsub(/[^a-zA-Z0-9\-]/, '_').squeeze('_')
  end
end
