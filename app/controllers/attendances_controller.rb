class AttendancesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: [:index]

  def index
    @attendances = @event.attendances.includes(:user) # Pour inclure les utilisateurs
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end
end
