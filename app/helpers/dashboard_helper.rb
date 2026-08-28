module DashboardHelper
  def sell_orders_counting_helper(sale)
    sell_order_counts = { items: 0, total: 0 }
    sale.orders.each do |order|
      order.order_products.each do |preparation|
        sell_order_counts[:items] = sell_order_counts[:items] + preparation.quantity
        sell_order_counts[:total] = sell_order_counts[:total] + (preparation.product.price * preparation.quantity)
      end
    end
    sell_order_counts
  end

  def status_kind_filter_params_helper(status, kind)
    return nil if status.nil? && kind.nil?
    return status if status && kind.nil?
    return kind if kind && status.nil?

    status.merge(kind)
  end

  def currency_helper(number)
    number_to_currency(number, precision: 0, locale: :es, separator: ",", delimiter: ".")
  end
end
