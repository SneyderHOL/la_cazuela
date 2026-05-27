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
