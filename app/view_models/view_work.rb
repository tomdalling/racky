require 'work_decorator'

class ViewModels::ViewWork
  def initialize(work)
    @work = work
  end

  def work
    @decorated_work ||= WorkDecorator.new(@work)
  end

  def title
    work.title
  end

  def author
    work.author
  end

  def body
    work.document_html
  end
end
