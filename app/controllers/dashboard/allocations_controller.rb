module Dashboard
  class AllocationsController < DashboardController
    before_action :set_allocation, only: %i[ show free reserve clean ]

    def index
      @allocations = Allocation.active_service(get_kinds, get_statuses).order(:kind, :name)
      if @allocations.any?
        @active_sell_orders = SellOrder.where(status: %i[ opened packed invoicing ])
                                      .sales_by_date(Time.zone.today)
                                      .where(allocation_id: @allocations.select(:id))
                                      .includes(:allocation, :orders)
                                      .order(created_at: :desc)
      else
        @active_sell_orders = []
      end
      allocations_kind_hashes
    end

    def show
    end

    def free
      @allocation.free!
      flash[:notice] = "Allocation was set to available."
      redirect_to dashboard_allocation_path(@allocation)
    rescue AASM::InvalidTransition => error
      flash[:alert] = "Unable to perform that action."
      render "dashboard/allocations/show", status: :unprocessable_content
    end

    def reserve
      @allocation.reserve!
      flash[:notice] = "Allocation was set to on hold."
      redirect_to dashboard_allocation_path(@allocation)
    rescue AASM::InvalidTransition => error
      flash[:alert] = "Unable to perform that action."
      render "dashboard/allocations/show", status: :unprocessable_content
    end

    def clean
      @allocation.clean!
      flash[:notice] = "Allocation was set to cleaning."
      redirect_to dashboard_allocation_path(@allocation)
    rescue AASM::InvalidTransition => error
      flash[:alert] = "Unable to perform that action."
      render "dashboard/allocations/show", status: :unprocessable_content
    end

    private

    def default_statuses = %i[ available busy on_hold cleaning ]

    def check_valid_status
      case params[:status]
      when "available" then :available
      when "busy" then :busy
      when "on_hold" then :on_hold
      when "cleaning" then :cleaning
      end
    end

    def get_statuses
      @param_status = check_valid_status
      if @param_status
        set_status_filter_param
        @param_status
      else
        default_statuses
      end
    end

    def allocations_kind_hashes
      @desks = {}
      @deliveries = {}
      @takeouts = {}
      @allocations.each do |allocation|
        @desks[allocation.id] = [] if allocation.desk?
        @deliveries[allocation.id] = [] if allocation.delivery?
        @takeouts[allocation.id] = [] if allocation.takeout?
      end
      @active_sell_orders.each do |sell_order|
        if @desks[sell_order.allocation_id]
          @desks[sell_order.allocation_id].push(sell_order)
          next
        elsif @deliveries[sell_order.allocation_id]
          @deliveries[sell_order.allocation_id].push(sell_order)
          next
        elsif @takeouts[sell_order.allocation_id]
          @takeouts[sell_order.allocation_id].push(sell_order)
        end
      end
    end

    def set_allocation
      @allocation = Allocation.includes(
        sell_orders: { orders: { order_products: :product } }
      ).find(params[:id])
      @sell_orders = @allocation.sell_orders.current_open_sales.order(created_at: :asc)
      @suborders_count = @sell_orders.sum { |so| so.orders.count }
    end
  end
end
