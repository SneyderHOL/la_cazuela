module Dashboard
  class SellOrdersController < DashboardController
    before_action :clear_flash, only: :index
    before_action :set_allocation, only: :create
    before_action :set_sell_order, only: %i[ show invoice deliver close payment ]

    def index
      @current_sales_counting = SellOrder.current_sales(
        default_statuses, default_kinds
      ).group(:status).count
      @current_sales_counting_by_kind = SellOrder.current_sales(
        default_statuses, default_kinds
      ).group("allocations.kind").count
      @current_sales = SellOrder.current_sales_with_products(get_statuses, get_kinds)
                                .order(updated_at: :desc)
    end

    def show
    end

    def invoice
      @sell_order.invoice!
      flash[:notice] = "Sell order was set to invoicing."
      redirect_to dashboard_sell_order_path(@sell_order)
    rescue AASM::InvalidTransition => error
      flash[:alert] = "Unable to perform that action."
      render "dashboard/sell_orders/show", status: :unprocessable_content
    end

    def deliver
      @sell_order.deliver!
      flash[:notice] = "Sell order was set to delivering."
      redirect_to dashboard_sell_order_path(@sell_order)
    rescue AASM::InvalidTransition => error
      flash[:alert] = "Unable to perform that action."
      render "dashboard/sell_orders/show", status: :unprocessable_content
    end

    def close
      @sell_order.close!
      flash[:notice] = "Sell order was closed."
      redirect_to dashboard_sell_order_path(@sell_order)
    rescue AASM::InvalidTransition => error
      flash[:alert] = "Unable to perform that action."
      render "dashboard/sell_orders/show", status: :unprocessable_content
    end

    def payment
      @sell_order.payment_type = params.expect(:payment_type)
      @sell_order.cash_pay = params.expect(:cash_pay) if @sell_order.cash?
      if @sell_order.save
        flash[:notice] = "Payment saved."
        redirect_to dashboard_sell_order_path(@sell_order)
      else
        flash[:alert] = @sell_order.errors.full_messages.join
        render "dashboard/sell_orders/show", status: :bad_request
      end
    rescue ActionController::ParameterMissing, ArgumentError => e
      flash[:alert] = e.message
      render "dashboard/sell_orders/show", status: :bad_request
    end

    def create
      @sell_order = SellOrder.create(allocation: @allocation)
      if @sell_order.persisted?
        @allocation.take!
        redirect_to new_dashboard_sell_order_order_path(@sell_order)
      else
        @sell_orders = @allocation.sell_orders.current_open_sales.order(created_at: :asc)
        @suborders_count = @sell_orders.sum { |so| so.orders.count }

        flash[:alert] = @sell_order.errors.full_messages.join
        render "dashboard/allocations/show", status: :bad_request
      end
    end

    private

    def default_statuses = %i[ opened packed invoicing delivering closed ]

    def check_valid_status
      case params[:status]
      when "opened" then :opened
      when "packed" then :packed
      when "invoicing" then :invoicing
      when "delivering" then :delivering
      when "closed" then :closed
      end
    end

    def set_sell_order
      @sell_order = SellOrder.includes(
        :allocation, :bill, orders: { order_products: :product }
      ).find(params[:id])
    end

    def set_allocation
      @allocation = Allocation.find(params[:allocation_id])
    end
  end
end
