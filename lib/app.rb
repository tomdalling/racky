require 'template'

class App
  def call(env)
    template = Template.new("<pre><%= self.inspect %></pre>")
    [
      200,
      { 'Content-Type' => 'text/html' },
      [template.render(env)]
    ]
  end
end
