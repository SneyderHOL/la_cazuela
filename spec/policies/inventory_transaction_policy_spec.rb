require 'rails_helper'

RSpec.describe InventoryTransactionPolicy, type: :policy do
  subject(:inventory_transaction_policy) { described_class.new(user, inventory_transaction) }

  let(:inventory_transaction) { create(:inventory_transaction, :with_ingredient) }

  context 'with admin' do
    let(:user) { User.new(role: :admin) }

    it "grants access for index" do
      expect(inventory_transaction_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(inventory_transaction_policy).to permit_action(:show)
    end

    it "grants access for create" do
      expect(inventory_transaction_policy).to permit_action(:create)
    end

    it "denies access for update" do
      expect(inventory_transaction_policy).not_to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(inventory_transaction_policy).not_to permit_action(:destroy)
    end
  end

  context 'with waiter' do
    let(:user) { User.new(role: :waiter) }

    it "denies access for index" do
      expect(inventory_transaction_policy).not_to permit_action(:index)
    end

    it "denies access for show" do
      expect(inventory_transaction_policy).not_to permit_action(:show)
    end

    it "denies access for create" do
      expect(inventory_transaction_policy).not_to permit_action(:create)
    end

    it "denies access for update" do
      expect(inventory_transaction_policy).not_to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(inventory_transaction_policy).not_to permit_action(:destroy)
    end
  end

  context 'with kitchen_auxiliar' do
    let(:user) { User.new(role: :kitchen_auxiliar) }

    it "denies access for index" do
      expect(inventory_transaction_policy).not_to permit_action(:index)
    end

    it "denies access for show" do
      expect(inventory_transaction_policy).not_to permit_action(:show)
    end

    it "denies access for create" do
      expect(inventory_transaction_policy).not_to permit_action(:create)
    end

    it "denies access for update" do
      expect(inventory_transaction_policy).not_to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(inventory_transaction_policy).not_to permit_action(:destroy)
    end
  end

  context "when user is nil" do
      let(:user) { nil }

      it { expect { inventory_transaction_policy }.to raise_error(Pundit::NotAuthorizedError, "must be logged in") }
  end
end
