module Dashboard
  class OrderProductsController < DashboardController
    before_action :clear_flash
    before_action :set_recent_preparations
    before_action :set_preparation, only: %i[ cook complete ]

    def index
    end

    def cook
      @preparation.cook!
      redirect_to dashboard_preparations_path(status: params[:status])
    rescue AASM::InvalidTransition => error
      flash[:alert] = "Unable to perform that action."
      render "dashboard/order_products/index", status: :unprocessable_content
    end

    def complete
      @preparation.complete!
      redirect_to dashboard_preparations_path(status: params[:status])
    rescue AASM::InvalidTransition => error
      flash[:alert] = "Unable to perform that action."
      render "dashboard/order_products/index", status: :unprocessable_content
    end

    private

    def set_recent_preparations
      @current_preparations_counting = OrderProduct.current_preparations_counting
      @recent_preparations = OrderProduct.current_preparations_with_sell_orders(
        get_statuses
      ).order(updated_at: :asc)
    end

    def default_statuses = %i[ requested prepare preparing completed ]

    def set_preparation = @preparation = OrderProduct.find(params[:id])
  end
end
