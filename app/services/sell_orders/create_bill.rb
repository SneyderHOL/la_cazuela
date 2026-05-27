module SellOrders
  class CreateBill
    attr_reader :sell_order, :detail, :total, :bill

    def initialize(sell_order)
      @sell_order = sell_order
      @detail = {}
      @total = 0
      @bill = nil
    end

    def call
      return if sell_order.opened? || sell_order.bill

      sell_order.orders.reload.each do |order|
        create_detail_hash(order)
      end
      calculate_total
      create_bill!
      sell_order.update(total: bill.total)
    end

    private

    def create_bill!
      @bill = Bill.create!(sell_order:, detail:, total:)
    end

    def calculate_total
      @total = detail.values.map { |product| product["subtotal"] }.sum
    end

    def create_detail_hash(order)
      order.order_products.each do |order_product|
        quantity = detail.dig(order_product.product.name, "quantity") || 0
        subtotal = detail.dig(order_product.product.name, "subtotal") || 0

        detail[order_product.product.name] = {
          "quantity" => quantity + order_product.quantity,
          "subtotal" => subtotal + (order_product.quantity * order_product.product.price)
        }
      end
    end
  end
end
