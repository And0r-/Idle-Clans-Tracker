class MembersController < ApplicationController
  before_action :set_period
  before_action :set_member
  
  def show
    @deposits = filtered_donations('deposit').limit(100)
    @withdraws = filtered_donations('withdraw').limit(100)
    @period_points = calculate_period_points
  end
  
  private
  
  def set_period
    @period = params[:period]&.to_sym || :all
    @period = :all unless [:today, :week, :all].include?(@period)
  end
  
  def set_member
    @member = Member.find_by!(username: params[:username])
  end
  
  def filtered_donations(transaction_type)
    base_query = @member.donations.where(transaction_type: transaction_type)
    
    case @period
    when :today
      base_query.where(occurred_at: Date.current.beginning_of_day..Date.current.end_of_day)
    when :week
      week_start = Date.current.beginning_of_week(:sunday)
      week_end = week_start.end_of_week(:sunday)
      base_query.where(occurred_at: week_start..week_end)
    else
      base_query
    end.order(occurred_at: :desc)
  end
  
  def calculate_period_points
    filtered_donations('deposit').sum(:points_value)
  end
end