require 'rails_helper'

RSpec.shared_examples "calls the CreateInventoryTransactionsJob" do
  it { expect(CreateInventoryTransactionsJob).to have_received(:perform_later) }
end

RSpec.shared_examples "not call the CreateInventoryTransactionsJob" do
  it { expect(CreateInventoryTransactionsJob).not_to have_received(:perform_later) }
end

RSpec.describe OrderProducts::UpdateInventoryOnCreation, type: :service do
  subject { described_class.new(order_product) }
  describe '#call' do
    let(:order_product) { build(:order_product, :with_order, product: product) }
    let(:product) { create(:product) }
    let(:stored_quantity) { 10 }
    let(:required_quantity) { 5 }
    let(:ingredient) { create(:ingredient, stored_quantity: stored_quantity) }
    let(:recipe) { create(:recipe, product: product) }
    let(:ingredient_recipe) do
      create(:ingredient_recipe, required_quantity: required_quantity,
        ingredient: ingredient, recipe: recipe)
    end

    before { allow(CreateInventoryTransactionsJob).to receive(:perform_later) }
    context "when parent product have a recipe" do
      context "with a non persisted order_product" do
        before do
          ingredient_recipe
          subject.call
          ingredient.reload
        end
        context "when the required_quantity does not exceeds the stored_quantity" do
          it "updates the stored_quantity to the related ingredient" do
            expect(ingredient.stored_quantity).to eql(5)
          end
          it "saves the order_product record" do
            expect(order_product).to be_persisted
          end
          it { is_expected.to be_succeeded }
          it_behaves_like "calls the CreateInventoryTransactionsJob"
        end

        context "when the required_quantity exceeds the stored_quantity" do
          let(:stored_quantity) { 4 }

          it "does not update the stored_quantity to the related ingredient" do
            expect(ingredient.stored_quantity).to eql(4)
          end
          it "does not save the order_product record" do
            expect(order_product).not_to be_persisted
          end
          it { is_expected.not_to be_succeeded }
          it_behaves_like "not call the CreateInventoryTransactionsJob"
        end
      end

      context "with a persisted order_product" do
        before do
          ingredient_recipe
          order_product.save
          subject.call
          ingredient.reload
        end

        it "does not update the stored_quantity to the related ingredient" do
          expect(ingredient.stored_quantity).to eql(10)
        end
        it { is_expected.not_to be_succeeded }
        it_behaves_like "not call the CreateInventoryTransactionsJob"
      end
    end
  end
end
