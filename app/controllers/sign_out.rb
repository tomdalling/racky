class Controllers::SignOut
  def call(env)
    Session.clear(env)
    [303, { 'Location' => '/' }, []]
  end
end
