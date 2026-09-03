module Dashboard
  class OrdersController < DashboardController
    before_action :set_sell_order, only: %i[ create new ]
    before_action :set_order, only: %i[ show edit update destroy confirm ]
    before_action :ensure_order_editable, only: %i[ edit update ]
    before_action :load_products, only: %i[ new edit ]

    def index
      if params[:sell_order_id]
        set_sell_order
        @orders = @sell_order.orders.includes(order_products: :product)
                                    .order(created_at: :asc)
        @current_orders_counting = @sell_order.orders.current.group(:status).count
        set_allocation
      else
        @orders = Order.recent(get_statuses).order(created_at: :desc)
        @current_orders_counting = Order.current.group(:status).count
      end
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
      redirect_to dashboard_order_path(@order),
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
      redirect_to dashboard_order_path(@order),
        notice: "Order created successfully."

    rescue ActiveRecord::RecordInvalid
      load_products
      render :new, status: :unprocessable_entity
    end

    def destroy
    end

    def confirm
      @order.confirm!
      flash[:notice] = "Sell order was sent to kitchen."
      redirect_to dashboard_order_path(@order)
    rescue AASM::InvalidTransition => error
      flash[:alert] = "Unable to perform that action."
      render "dashboard/orders/show", status: :unprocessable_content
    end

    # def pack
    #   @order.pack!
    #   flash[:notice] = "Sell order was packed."
    #   redirect_to dashboard_order_path(@order)
    # rescue AASM::InvalidTransition => error
    #   flash[:alert] = "Unable to perform that action."
    #   render "dashboard/orders/show", status: :unprocessable_content
    # end

    # def complete
    #   @order.complete!
    #   flash[:notice] = "Sell order was completed."
    #   redirect_to dashboard_order_path(@order)
    # rescue AASM::InvalidTransition => error
    #   flash[:alert] = "Unable to perform that action."
    #   render "dashboard/orders/show", status: :unprocessable_content
    # end

    private

    def set_sell_order
      @sell_order = SellOrder.includes(
        :allocation, orders: { order_products: :product }
      ).find(params[:sell_order_id])
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

    def default_statuses = %i[ opened processing packed completed ]

    def check_valid_status
      case params[:status]
      when "opened" then :opened
      when "processing" then :processing
      when "packed" then :packed
      when "completed" then :completed
      end
    end
  end
end
