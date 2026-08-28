module Dashboard
  class OrdersController < DashboardController
    before_action :set_sell_order

    def index
    end

    def show
      @order = @sell_order.orders.includes(order_products: :product).find(params[:id])
    end

    def new
      @order = @sell_order.orders.build

      load_products
    end

    def create
      ActiveRecord::Base.transaction do
        @order = @sell_order.orders.create!(order_params)
      end

      flash[:notice] = "Order created successfully."
      redirect_to dashboard_allocation_path(@allocation)

    rescue ActiveRecord::RecordInvalid
      load_products
      render :new, status: :unprocessable_entity
    end

    private

    def set_sell_order
      if params[:sell_order_id]
        @sell_order = SellOrder.includes(:allocation).find(params[:sell_order_id])
        @allocation = @sell_order.allocation
      else
        @orders = Order.recent
      end
    end

    def order_params
      params.require(:order).permit(
        order_products_attributes: [ :product_id, :quantity, :note ]
      )
    end

    def load_products
      @categories = Category.where(active: true).includes(:products).order(:name)
      @products = Product.where(active: true).includes(:category).order(:name)
    end
  end
end
