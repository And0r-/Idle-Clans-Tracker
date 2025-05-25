class MembersController < ApplicationController
  before_action :set_period, only: [:show]
  before_action :set_member, only: [:show]
  
  def show
    @deposits = filtered_donations('deposit').limit(100)
    @withdraws = filtered_donations('withdraw').limit(100)
    @period_points = calculate_period_points
  end
  
  def toggle_donation_excluded
    @donation = Donation.find(params[:donation_id])
    @donation.update!(excluded: !@donation.excluded?)
    
    respond_to do |format|
      format.html { redirect_back(fallback_location: member_path(@donation.member.username)) }
      format.json { render json: { excluded: @donation.excluded? } }
    end
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
      today_start = Time.current.in_time_zone('Europe/Zurich').beginning_of_day
      today_end = Time.current.in_time_zone('Europe/Zurich').end_of_day
      base_query.where(occurred_at: today_start..today_end)
    when :week
      week_start = Time.current.in_time_zone('Europe/Zurich').beginning_of_week(:sunday)
      week_end = Time.current.in_time_zone('Europe/Zurich').end_of_week(:sunday)
      base_query.where(occurred_at: week_start..week_end)
    else
      base_query
    end.order(occurred_at: :desc)
  end
  
  def calculate_period_points
    filtered_donations('deposit')
      .counted
      .joins('LEFT JOIN item_values ON donations.item_name = item_values.item_name AND item_values.active = true')
      .sum('donations.quantity * COALESCE(item_values.points_per_unit, 0)')
  end
end