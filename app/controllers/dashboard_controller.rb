class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @consumptions = current_user.consumptions.includes(:utility_type).order(created_at: :desc)
  end
end
