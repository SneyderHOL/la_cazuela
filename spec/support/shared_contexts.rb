# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.shared_context "with sell_order composite" do
  let(:product_one) { create(:product, :with_recipe, :with_category, price: 15_000) }
  let(:product_two) { create(:product, :with_recipe, :with_category, price: 10_000) }
  let(:product_three) { create(:product, :with_recipe, :with_category, price: 5_000) }
  let(:product_four) { create(:product, :with_recipe, :with_category, price: 4_000) }
  let(:order_one) { create(:order, :as_completed, sell_order: sell_order) }
  let(:order_two) { create(:order, :as_completed, sell_order: sell_order) }
  let(:order_three) { create(:order, :as_completed, sell_order: sell_order) }
  let(:expected_detail) do
    {
      product_one.name => { "quantity" => 6, "subtotal" => 90_000 },
      product_two.name => { "quantity" => 5, "subtotal" => 50_000 },
      product_three.name => { "quantity" => 8, "subtotal" => 40_000 },
      product_four.name => { "quantity" => 1, "subtotal" => 4_000 }
    }
  end

  before do
    create(:order_product, order: order_one, product: product_one, quantity: 5)
    create(:order_product, order: order_one, product: product_two, quantity: 4)
    create(:order_product, order: order_two, product: product_three, quantity: 3)
    create(:order_product, order: order_two, product: product_one, quantity: 1)
    create(:order_product, order: order_two, product: product_three, quantity: 5)
    create(:order_product, order: order_three, product: product_two, quantity: 1)
    create(:order_product, order: order_three, product: product_four, quantity: 1)
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers

RSpec.shared_context "with sell_order soft composite" do
  let(:product_one) { create(:product, :with_recipe, :with_category, price: 15_000) }
  let(:order_one) { create(:order, :as_completed, sell_order: sell_order) }
  let(:expected_detail) do
    {
      product_one.name => { "quantity" => 5, "subtotal" => 75_000 }
    }
  end

  before do
    create(:order_product, order: order_one, product: product_one, quantity: 5)
  end
end

RSpec.shared_context "with sell_order close transition valid cash validation" do
  before do
    sell_order.payment_type = "cash"
    sell_order.total = 20_000
    sell_order.cash_pay = 30_000
    sell_order.cash_change = 10_000
  end
end

RSpec.shared_context "with sell_orders for scopes" do
  let(:thursday) { Time.zone.local(2026, 5, 21, 13, 30, 0) }
  let(:friday) { Time.zone.local(2026, 5, 22, 13, 30, 0) }
  let(:saturday) { Time.zone.local(2026, 5, 23, 13, 30, 0) }

  before do
    create_sell_orders
  end

=begin
  sell_order: :with_transfer_payment, created_at: thursday, total: nil, status: "opened")
  sell_order: :with_transfer_payment, created_at: friday, total: 1_000, status: "opened")
  sell_order: :with_transfer_payment, created_at: saturday, total: 10_000, status: "opened")
  sell_order: :with_card_payment, created_at: thursday, total: nil, status: "opened")
  sell_order: :with_card_payment, created_at: friday, total: 2_000, status: "opened")
  sell_order: :with_card_payment, created_at: saturday, total: 20_000, status: "opened")
  sell_order: :with_cash_payment, created_at: thursday, total: nil, status: "opened")
  sell_order: :with_cash_payment, created_at: friday, total: 3_000, cash_pay: 3_000, cash_change: 0, status: "opened")
  sell_order: :with_cash_payment, created_at: saturday, total: 30_000, cash_pay: 30_000, cash_change: 0, status: "opened")
  sell_order: :with_transfer_payment, created_at: thursday, total: nil, status: "packed")
  sell_order: :with_transfer_payment, created_at: friday, total: 4_000, status: "packed")
  sell_order: :with_transfer_payment, created_at: saturday, total: 40_000, status: "packed")
  sell_order: :with_card_payment, created_at: thursday, total: nil, status: "packed")
  sell_order: :with_card_payment, created_at: friday, total: 5_000, status: "packed")
  sell_order: :with_card_payment, created_at: saturday, total: 50_000, status: "packed")
  sell_order: :with_cash_payment, created_at: thursday, total: nil, status: "packed")
  sell_order: :with_cash_payment, created_at: friday, total: 6_000, cash_pay: 6_000, cash_change: 0, status: "packed")
  sell_order: :with_cash_payment, created_at: saturday, total: 60_000, cash_pay: 60_000, cash_change: 0, status: "packed")
  sell_order: :with_transfer_payment, created_at: thursday, total: 700, status: "invoicing")
  sell_order: :with_transfer_payment, created_at: friday, total: 7_000, status: "invoicing")
  sell_order: :with_transfer_payment, created_at: saturday, total: 70_000, status: "invoicing")
  sell_order: :with_card_payment, created_at: thursday, total: 800, status: "invoicing")
  sell_order: :with_card_payment, created_at: friday, total: 8_000, status: "invoicing")
  sell_order: :with_card_payment, created_at: saturday, total: 80_000, status: "invoicing")
  sell_order: :with_cash_payment, created_at: thursday, total: 900, cash_pay: 900, cash_change: 0, status: "invoicing")
  sell_order: :with_cash_payment, created_at: friday, total: 9_000, cash_pay: 9_000, cash_change: 0, status: "invoicing")
  sell_order: :with_cash_payment, created_at: saturday, total: 90_000, cash_pay: 90_000, cash_change: 0, status: "invoicing")
  sell_order: :with_transfer_payment, created_at: thursday, total: 1_000, status: "delivering")
  sell_order: :with_transfer_payment, created_at: friday, total: 10_000, status: "delivering")
  sell_order: :with_transfer_payment, created_at: saturday, total: 100_000, status: "delivering")
  sell_order: :with_card_payment, created_at: thursday, total: 1_100, status: "delivering")
  sell_order: :with_card_payment, created_at: friday, total: 11_000, status: "delivering")
  sell_order: :with_card_payment, created_at: saturday, total: 110_000, status: "delivering")
  sell_order: :with_cash_payment, created_at: thursday, total: 1_200, cash_pay: 1_200, cash_change: 0, status: "delivering")
  sell_order: :with_cash_payment, created_at: friday, total: 12_000, cash_pay: 12_000, cash_change: 0, status: "delivering")
  sell_order: :with_cash_payment, created_at: saturday, total: 120_000, cash_pay: 120_000, cash_change: 0, status: "delivering")
  sell_order: :with_transfer_payment, created_at: thursday, total: 1_300, status: "closed")
  sell_order: :with_transfer_payment, created_at: friday, total: 13_000, status: "closed")
  sell_order: :with_transfer_payment, created_at: saturday, total: 130_000, status: "closed")
  sell_order: :with_card_payment, created_at: thursday, total: 1_400, status: "closed")
  sell_order: :with_card_payment, created_at: friday, total: 14_000, status: "closed")
  sell_order: :with_card_payment, created_at: saturday, total: 140_000, status: "closed")
  sell_order: :with_cash_payment, created_at: thursday, total: 1_500, cash_pay: 1_500, cash_change: 0, status: "closed")
  sell_order: :with_cash_payment, created_at: friday, total: 15_000, cash_pay: 15_000, cash_change: 0, status: "closed")
  sell_order: :with_cash_payment, created_at: saturday, total: 150_000, cash_pay: 150_000, cash_change: 0, status: "closed")
=end
  def create_sell_orders
    statuses = [ "opened", "packed", "invoicing", "delivering", "closed" ]
    factors = [ 1_000, 10_000 ]
    dates = [ thursday, friday, saturday ]
    total_initials = (1..15).to_a
    payment_types = [ :with_transfer_payment, :with_card_payment, :with_cash_payment ]
    total_index = 0

    statuses.each_with_index do |status, status_index|
      payment_types.each_with_index do |payment_type, payment_idx|
        dates.each_with_index do |date, date_idx|
          cash_pay = nil
          cash_change = nil
          if status == "invoicing" || status == "delivering" || status == "closed"
            total = date_idx.zero? ? ((total_initials[total_index] * factors[date_idx]) * 0.1).to_i : total_initials[total_index] * factors[date_idx - 1]
            cash_pay = total if payment_idx == 2
            cash_change = 0 if payment_idx == 2
          else
            total = date_idx.zero? ? nil : total_initials[total_index] * factors[date_idx - 1]
            cash_pay = total if payment_idx == 2
          end
          if status == "delivering"
            create(:sell_order, :with_delivery_allocation, payment_type, created_at: date, total:, cash_pay:, cash_change:, status:)
          else
            create(:sell_order, :with_allocation, payment_type, created_at: date, total:, cash_pay:, cash_change:, status:)
          end
        end
        total_index += 1
      end
    end
  end
end

RSpec.shared_context "with a category tree" do
  let(:dish_category) { create(:category, :with_active_on, name: "Dish") }
  let(:dish_subcategories) do
    create(:category, :with_active_on, :with_products, trait_products_amount: 3, parent: dish_category, name: "Main")
    create(:category, :with_active_on, :with_products, trait_products_amount: 2, parent: dish_category, name: "Entry")
    dish_aside = create(:category, :with_active_on, :with_products, trait_products_amount: 1, parent: dish_category, name: "Aside")
    create(:category, :with_active_on, :with_products, trait_products_amount: 1, parent: dish_aside, name: "Dessert")
  end

  before { dish_subcategories }
end

RSpec.shared_context "with orders for scopes" do
  let(:thursday) { Time.zone.local(2026, 5, 21, 13, 30, 0) }
  let(:friday) { Time.zone.local(2026, 5, 22, 13, 30, 0) }
  let(:saturday) { Time.zone.local(2026, 5, 23, 13, 30, 0) }

  before { create_orders }

=begin
  order: created_at: thursday, status: "opened")
  order: created_at: friday, status: "opened")
  order: created_at: saturday, status: "opened")
  order: created_at: thursday, status: "processing")
  order: created_at: friday, status: "processing")
  order: created_at: saturday, status: "processing")
  order: created_at: thursday, status: "packed")
  order: created_at: friday, status: "packed")
  order: created_at: saturday, status: "packed")
  order: created_at: thursday, status: "completed")
  order: created_at: friday, status: "completed")
  order: created_at: saturday, status: "completed")
=end
  def create_orders
    statuses = [ "opened", "processing", "packed", "completed" ]
    dates = [ thursday, friday, saturday ]

    statuses.each_with_index do |status|
      dates.each do |date|
        create(:order, :with_sell_order, created_at: date, status:)
      end
    end
  end
end

RSpec.shared_context "with orders and order_products for scopes" do
  let(:thursday) { Time.zone.local(2026, 5, 21, 13, 30, 0) }
  let(:friday) { Time.zone.local(2026, 5, 22, 13, 30, 0) }
  let(:saturday) { Time.zone.local(2026, 5, 23, 13, 30, 0) }
  let(:beverage) do
    create(:product, :with_recipe, name: "Lemonade", category: create(:category, :with_active_on, name: "Soda"))
  end
  let(:dish) do
    create(:product, :with_recipe, name: "Chicken with rice", category: create(:category, :with_active_on, name: "Spicy"))
  end

  before { create_orders_and_order_products }

=begin
  order: created_at: thursday, status: "opened")
    order_product: product: beverage, quantity: 1, created_at: thursday, created_at: date, status: "requested"
    order_product: product: dish, quantity: 1, created_at: thursday, status: "requested"
  order: created_at: thursday, status: "processing")
    order_product: product: beverage, quantity: 1, created_at: thursday, status: "prepare"
    order_product: product: dish, quantity: 1, created_at: thursday, status: "prepare"
  order: created_at: thursday, status: "processing")
    order_product: product: beverage, quantity: 1, created_at: thursday, status: "preparing"
    order_product: product: dish, quantity: 1, created_at: thursday, status: "preparing"
  order: created_at: thursday, status: "processing")
    order_product: product: beverage, quantity: 1, created_at: thursday, status: "completed"
    order_product: product: dish, quantity: 1, created_at: thursday, status: "completed"
  order: created_at: thursday, status: "packed")
    order_product: product: beverage, quantity: 1, created_at: thursday, status: "completed"
    order_product: product: dish, quantity: 1, created_at: thursday, status: "completed"
  order: created_at: thursday, status: "completed")
    order_product: product: beverage, quantity: 1, created_at: thursday, status: "completed"
    order_product: product: dish, quantity: 1, created_at: thursday, status: "completed"
  --
  order: created_at: friday, status: "opened")
    order_product: product: beverage, quantity: 1, created_at: friday, status: "requested"
    order_product: product: dish, quantity: 1, created_at: friday, status: "requested"
  order: created_at: friday, status: "processing")
    order_product: product: beverage, quantity: 1, created_at: friday, status: "prepare"
    order_product: product: dish, quantity: 1, created_at: friday, status: "prepare"
  order: created_at: friday, status: "processing")
    order_product: product: beverage, quantity: 1, created_at: friday, status: "preparing"
    order_product: product: dish, quantity: 1, created_at: friday, status: "preparing"
  order: created_at: friday, status: "processing")
    order_product: product: beverage, quantity: 1, created_at: friday, status: "completed"
    order_product: product: dish, quantity: 1, created_at: friday, status: "completed"
  order: created_at: friday, status: "packed")
    order_product: product: beverage, quantity: 1, created_at: friday, status: "completed"
    order_product: product: dish, quantity: 1, created_at: friday, status: "completed"
  order: created_at: friday, status: "completed")
    order_product: product: beverage, quantity: 1, created_at: friday, status: "completed"
    order_product: product: dish, quantity: 1, created_at: friday, status: "completed"
  --
  order: created_at: saturday, status: "opened")
    order_product: product: beverage, quantity: 1, created_at: saturday, status: "requested"
    order_product: product: dish, quantity: 1, created_at: saturday, status: "requested"
  order: created_at: saturday, status: "processing")
    order_product: product: beverage, quantity: 1, created_at: saturday, status: "prepare"
    order_product: product: dish, quantity: 1, created_at: saturday, status: "prepare"
  order: created_at: saturday, status: "processing")
    order_product: product: beverage, quantity: 1, created_at: saturday, status: "preparing"
    order_product: product: dish, quantity: 1, created_at: saturday, status: "preparing"
  order: created_at: saturday, status: "processing")
    order_product: product: beverage, quantity: 1, created_at: saturday, status: "completed"
    order_product: product: dish, quantity: 1, created_at: saturday, status: "completed"
  order: created_at: saturday, status: "packed")
    order_product: product: beverage, quantity: 1, created_at: saturday, status: "completed"
    order_product: product: dish, quantity: 1, created_at: saturday, status: "completed"
  order: created_at: saturday, status: "completed")
    order_product: product: beverage, quantity: 1, created_at: saturday, status: "completed"
    order_product: product: dish, quantity: 1, created_at: saturday, status: "completed"
=end
  def create_orders_and_order_products
    statuses = [ "opened", "processing", "packed", "completed" ]
    order_product_statuses = [ "requested", "prepare", "preparing", "completed" ]
    dates = [ thursday, friday, saturday ]

    statuses.each_with_index do |status|
      dates.each do |date|
        order_product_statuses.each do |op_status|
          if (status == "opened" && op_status == "requested") ||
             (status == "processing" && [ "prepare", "preparing", "completed" ].include?(op_status)) ||
             (status == "packed" && op_status == "completed") ||
             (status == "completed" && op_status == "completed")
            order = create(:order, :with_sell_order, created_at: date, status:)
            create(:order_product, order:, product: beverage, quantity: 1, created_at: date, status: op_status)
            create(:order_product, order:, product: dish, quantity: 1, created_at: date, status: op_status)
          end
        end
      end
    end
  end
end
