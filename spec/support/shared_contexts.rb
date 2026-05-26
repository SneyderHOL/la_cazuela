# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.shared_context "with sell_order composite" do
  let(:product_one) { create(:product, :with_recipe, price: 15_000) }
  let(:product_two) { create(:product, :with_recipe, price: 10_000) }
  let(:product_three) { create(:product, :with_recipe, price: 5_000) }
  let(:product_four) { create(:product, :with_recipe, price: 4_000) }
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
  let(:product_one) { create(:product, :with_recipe, price: 15_000) }
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

  before { create_sell_orders }

=begin
  sell_order: :with_transfer_payment, created_at: thursday, total: nil, status: "opened")
  sell_order: :with_transfer_payment, created_at: friday, total: 1_000, status: "opened")
  sell_order: :with_transfer_payment, created_at: saturday, total: 10_000, status: "opened")
  sell_order: :with_card_payment, created_at: thursday, total: nil, status: "opened")
  sell_order: :with_card_payment, created_at: friday, total: 2_000, status: "opened")
  sell_order: :with_card_payment, created_at: saturday, total: 20_000, status: "opened")
  sell_order: :with_cash_payment, created_at: thursday, total: nil, status: "opened")
  sell_order: :with_cash_payment, created_at: friday, total: 3_000, status: "opened")
  sell_order: :with_cash_payment, created_at: saturday, total: 30_000, status: "opened")
  sell_order: :with_transfer_payment, created_at: thursday, total: nil, status: "packed")
  sell_order: :with_transfer_payment, created_at: friday, total: 4_000, status: "packed")
  sell_order: :with_transfer_payment, created_at: saturday, total: 40_000, status: "packed")
  sell_order: :with_card_payment, created_at: thursday, total: nil, status: "packed")
  sell_order: :with_card_payment, created_at: friday, total: 5_000, status: "packed")
  sell_order: :with_card_payment, created_at: saturday, total: 50_000, status: "packed")
  sell_order: :with_cash_payment, created_at: thursday, total: nil, status: "packed")
  sell_order: :with_cash_payment, created_at: friday, total: 6_000, status: "packed")
  sell_order: :with_cash_payment, created_at: saturday, total: 60_000, status: "packed")
  sell_order: :with_transfer_payment, created_at: thursday, total: 700, status: "invoicing")
  sell_order: :with_transfer_payment, created_at: friday, total: 7_000, status: "invoicing")
  sell_order: :with_transfer_payment, created_at: saturday, total: 70_000, status: "invoicing")
  sell_order: :with_card_payment, created_at: thursday, total: 800, status: "invoicing")
  sell_order: :with_card_payment, created_at: friday, total: 8_000, status: "invoicing")
  sell_order: :with_card_payment, created_at: saturday, total: 80_000, status: "invoicing")
  sell_order: :with_cash_payment, created_at: thursday, total: 900, cash_pay: 900, cash_change: 0, status: "invoicing")
  sell_order: :with_cash_payment, created_at: friday, total: 9_000, cash_pay: 9_000, cash_change: 0, status: "invoicing")
  sell_order: :with_cash_payment, created_at: saturday, total: 90_000, cash_pay: 90_000, cash_change: 0, status: "invoicing")
  sell_order: :with_transfer_payment, created_at: thursday, total: 1_000, status: "closed")
  sell_order: :with_transfer_payment, created_at: friday, total: 10_000, status: "closed")
  sell_order: :with_transfer_payment, created_at: saturday, total: 100_000, status: "closed")
  sell_order: :with_card_payment, created_at: thursday, total: 1_100, status: "closed")
  sell_order: :with_card_payment, created_at: friday, total: 11_000, status: "closed")
  sell_order: :with_card_payment, created_at: saturday, total: 110_000, status: "closed")
  sell_order: :with_cash_payment, created_at: thursday, total: 1_200, cash_pay: 1_200, cash_change: 0, status: "closed")
  sell_order: :with_cash_payment, created_at: friday, total: 12_000, cash_pay: 12_000, cash_change: 0, status: "closed")
  sell_order: :with_cash_payment, created_at: saturday, total: 120_000, cash_pay: 120_000, cash_change: 0, status: "closed")
=end
  def create_sell_orders
    statuses = [ "opened", "packed", "invoicing", "closed" ]
    factors = [ 1_000, 10_000 ]
    dates = [ thursday, friday, saturday ]
    total_initials = (1..12).to_a
    payment_types = [ :with_transfer_payment, :with_card_payment, :with_cash_payment ]
    total_index = 0

    statuses.each_with_index do |status, status_index|
      payment_types.each_with_index do |payment_type, payment_idx|
        dates.each_with_index do |date, date_idx|
          cash_pay = nil
          cash_change = nil
          if status == "invoicing" || status == "closed"
            total = date_idx.zero? ? ((total_initials[total_index] * factors[date_idx]) * 0.1).to_i : total_initials[total_index] * factors[date_idx - 1]
            cash_pay = total if payment_idx == 2
            cash_change = 0 if payment_idx == 2
          else
            total = date_idx.zero? ? nil : total_initials[total_index] * factors[date_idx - 1]
          end
          create(:sell_order, :with_allocation, payment_type, created_at: date, total:, cash_pay:, cash_change:, status:)
        end
        total_index += 1
      end
    end
  end
end
