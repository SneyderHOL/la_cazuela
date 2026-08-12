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

  def set_status_filter_param = @status_filter_param = { status: params[:status] }

  def set_kind_filter_param = @kind_filter_param = { kind: params[:kind] }

  def default_statuses = nil

  def check_valid_status = nil

  def default_kinds = %i[ desk delivery takeout ]

  def clear_flash = flash.clear

  def get_statuses
    @param_status = check_valid_status
    if @param_status
      set_status_filter_param
      @param_status
    else
      default_statuses
    end
  end

  def get_kinds
    @param_kind = check_valid_kind
    if @param_kind
      set_kind_filter_param
      @param_kind
    else
      default_kinds
    end
  end

  def check_valid_kind
    case params[:kind]
    when "desk" then :desk
    when "delivery" then :delivery
    when "takeout" then :takeout
    end
  end
end
