class DashboardController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"

  def index
    @opened_orders_count = Order.current_open.count
    @preparing_order_products_count = OrderProduct.current_preparations.preparing.count
    @completed_order_products_count = OrderProduct.current_preparations.completed.count
    @pending_delivering_sell_orders_count = SellOrder.current_sales(
      %i[ opened packed invoicing ], :delivery
    ).count
    @desk_allocations = Allocation.desk.active
    @recent_orders = Order.recent.limit(10)
    @recent_preparations = OrderProduct.current_preparations_with_sell_orders(
      %i[ requested prepare preparing ]
    ).order(updated_at: :desc).limit(10)
    @unclosed_sell_orders = SellOrder.unclosed.limit(10)
  end

  private

  def check_valid_status
    case params[:status]
    when "opened" then :opened
    when "packed" then :packed
    when "invoicing" then :invoicing
    when "delivering" then :delivering
    when "closed" then :closed
    when "requested" then :requested
    when "prepare", "preparing" then %i[ prepare preparing ]
    when "completed" then :completed
    end
  end

  def set_status_filter_param = @status_filter_param = { status: params[:status] }

  def get_statuses
    @param_status = check_valid_status
    if @param_status
      set_status_filter_param
      @param_status
    else
      default_statuses
    end
  end

  def clear_flash = flash.clear

  def default_statuses = nil
end
