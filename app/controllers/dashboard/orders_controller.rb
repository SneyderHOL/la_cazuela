module Dashboard
  class OrdersController < DashboardController
    before_action :set_sell_order
    before_action :set_order, only: %i[ show edit update destroy confirm complete]
    before_action :ensure_order_editable, only: %i[ edit update ]
    before_action :load_products, only: %i[ new edit ]

    def index
      @orders ||= @sell_order.orders.includes(order_products: :product)
                                    .order(created_at: :asc)
    end

    def show
    end

    def new
      @order = @sell_order.orders.build
    end

    def edit
    end

    def update
      ActiveRecord::Base.transaction do
        @order.update!(order_params)
      end

      # flash[:notice] = "Order updated successfully."
      redirect_to dashboard_allocation_path(@allocation),
        notice: "Order updated successfully."

    rescue ActiveRecord::RecordInvalid
      load_products
      render :edit, status: :unprocessable_entity
    end

    def create
      ActiveRecord::Base.transaction do
        @order = @sell_order.orders.create!(order_params)
      end

      # flash[:notice] = "Order created successfully."
      redirect_to dashboard_allocation_path(@allocation),
        notice: "Order sent successfully."

    rescue ActiveRecord::RecordInvalid
      load_products
      render :new, status: :unprocessable_entity
    end

    def destroy
    end

    def confirm
    end

    def complete
    end

    private

    def set_sell_order
      if params[:sell_order_id]
        @sell_order = SellOrder.includes(:allocation).find(params[:sell_order_id])
        set_allocation
      else
        @orders = Order.recent
      end
    end

    def set_order
      @order = Order.includes(sell_order: :allocation, order_products: :product).find(params[:id])
      @sell_order = @order.sell_order
      set_allocation
    end

    def set_allocation
      @allocation = @sell_order.allocation
    end

    def order_params
      params.require(:order).permit(
        order_products_attributes: [ :id, :product_id, :quantity, :note, :_destroy ]
      )
    end

    def load_products
      @categories = Category.where(active: true).includes(:products).order(:name)
      @products = Product.where(active: true).includes(:category).order(:name)
    end

    def ensure_order_editable
      unless @order.status == "opened"
        redirect_to dashboard_order_path(@order),
          alert: "This order can no longer be edited."
      end
    end
  end
end
