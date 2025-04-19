module Orders
  class CreateBill
    def initialize(order)
      @order = order
      @detail = {}
      @total = 0
    end

    def call
      return unless @order&.closed? && @order&.parent_id.nil?

      @order.suborders.each do |order|
        create_detail_hash(order)
      end
      create_detail_hash(@order)
      calculate_total
      create_bill!
    end

    private

    def create_bill!
      Bill.create!(order: @order, detail: @detail, total: @total)
    end

    def calculate_total
      @total = @detail.values.map { |product| product["subtotal"] }.sum
    end

    def create_detail_hash(order)
      order.order_products.each do |order_product|
        quantity = @detail.dig(order_product.product.name, "quantity") || 0
        subtotal = @detail.dig(order_product.product.name, "subtotal") || 0

        @detail[order_product.product.name] = {
          "quantity" => quantity + order_product.quantity,
          "subtotal" => subtotal + (order_product.quantity * order_product.product.price)
        }
      end
    end
  end
end
