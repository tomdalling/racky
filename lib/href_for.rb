module HrefFor
  extend self

  def bio; '/bio'; end
  def dashboard; '/dashboard'; end
  def homepage; '/'; end
  def sign_in; '/auth/sign_in'; end
  def sign_out; '/auth/sign_out'; end
  def upload_work; '/works/upload'; end

  def work(work)
    fail "Work must have author preloaded" unless work.author
    "/@#{work.author.machine_name}/#{work.machine_name}"
  end

  def [](obj)
    case obj
    when Symbol then send(obj)
    when Work, WorkDecorator then work(obj)
    else fail "Don't know how to make a href for #{obj.inspect}"
    end
  end
end
