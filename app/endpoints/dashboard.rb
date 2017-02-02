class Endpoints::Dashboard < RequestHandler
  dependencies fetch_dashboard: 'queries/dashboard'

  def run
    dashboard = fetch_dashboard.(current_user)
    render(:dashboard, works: dashboard.works)
  end
end
