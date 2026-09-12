module Dashboard
  class OrderProductsController < DashboardController
    before_action :set_recent_preparations, only: :index
    before_action :set_preparation, only: %i[ cook complete destroy ]

    def index
    end

    def cook
      @preparation.cook!

      redirect_to dashboard_preparations_path(status: params[:status]), notice: "Preparation is being cook."
    rescue AASM::InvalidTransition => error
      set_recent_preparations
      flash[:alert] = "Unable to perform that action."
      render "dashboard/order_products/index", status: :unprocessable_content
    end

    def complete
      @preparation.complete!

      redirect_to dashboard_preparations_path(status: params[:status]), notice: "Preparation is done."
    rescue AASM::InvalidTransition => error
      set_recent_preparations
      flash[:alert] = "Unable to perform that action."
      render "dashboard/order_products/index", status: :unprocessable_content
    end

    def destroy
      @preparation.destroy!

      redirect_to dashboard_order_path(@preparation.order), notice: "Preparation was destroyed successfully."
    rescue ActiveRecord::RecordNotDestroyed => _e
      set_parent_order_resources
      flash[:alert] = @preparation.errors.full_messages.join
      render "dashboard/orders/show", status: :unprocessable_content
    end

    private

    def set_recent_preparations
      @current_preparations_counting = OrderProduct.current_preparations_counting
      @recent_preparations = OrderProduct.current_preparations_with_sell_orders(
        get_statuses
      ).order(updated_at: :asc)
    end

    def default_statuses = %i[ requested prepare preparing completed ]

    def set_preparation = @preparation = OrderProduct.includes(:order).find(params[:id])

    def check_valid_status
      case params[:status]
      when "requested" then :requested
      when "prepare", "preparing" then %i[ prepare preparing ]
      when "completed" then :completed
      end
    end

    def set_parent_order_resources
      @order = @preparation.order
      @sell_order = @order.sell_order
      @allocation = @sell_order.allocation
    end
  end
end
