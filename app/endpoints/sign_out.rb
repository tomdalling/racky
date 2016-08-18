class Endpoints::SignOut
  def call(env)
    Session.clear(env)
    [303, { 'Location' => '/' }, []]
  end
end