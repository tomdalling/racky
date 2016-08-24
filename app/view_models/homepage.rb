require 'work_decorator'

class ViewModels::Homepage
  def initialize(home)
    @home = home
  end

  def featured_work
    @featured_work ||= wrap(:featured, WorkDecorator)
  end

  def latest_work
    @latest_work ||= wrap(:latest, WorkDecorator)
  end

  def wrap(key, klass)
    obj = @home[key]
    obj.nil? ? nil : klass.new(obj)
  end
end
