require 'rails_helper'

RSpec.describe SellOrderPolicy, type: :policy do
  subject(:sell_order_policy) { described_class.new(user, sell_order) }

  context 'with admin and opened sell_order' do
    let(:user) { User.new(role: :admin) }
    let(:sell_order) { create(:sell_order, :with_allocation, status: "opened") }

    it { is_expected.to permit_all_actions }
  end

  context 'with waiter and opened sell_order' do
    let(:user) { User.new(role: :waiter) }
    let(:sell_order) { create(:sell_order, :with_allocation, status: "opened") }

    it { is_expected.to permit_all_actions }
  end

  context 'with kitchen_auxiliar and opened sell_order' do
    let(:user) { User.new(role: :kitchen_auxiliar) }
    let(:sell_order) { create(:sell_order, :with_allocation, status: "opened") }

    it "grants access for index" do
      expect(sell_order_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(sell_order_policy).to permit_action(:show)
    end

    it "denies access for create" do
      expect(sell_order_policy).not_to permit_action(:create)
    end

    it "denies access for update" do
      expect(sell_order_policy).not_to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(sell_order_policy).not_to permit_action(:destroy)
    end
  end

  context 'with cashier and opened sell_order' do
    let(:user) { User.new(role: :cashier) }
    let(:sell_order) { create(:sell_order, :with_allocation, status: "opened") }

    it "grants access for index" do
      expect(sell_order_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(sell_order_policy).to permit_action(:show)
    end

    it "denies access for create" do
      expect(sell_order_policy).not_to permit_action(:create)
    end

    it "denies access for update" do
      expect(sell_order_policy).not_to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(sell_order_policy).not_to permit_action(:destroy)
    end
  end

  context 'with admin and delivering sell_order' do
    let(:user) { User.new(role: :admin) }
    let(:sell_order) { create(:sell_order, :with_allocation, status: "delivering") }

    it "grants access for index" do
      expect(sell_order_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(sell_order_policy).to permit_action(:show)
    end

    it "grants access for create" do
      expect(sell_order_policy).to permit_action(:create)
    end

    it "grants access for update" do
      expect(sell_order_policy).to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(sell_order_policy).not_to permit_action(:destroy)
    end
  end

  context 'with waiter and delivering sell_order' do
    let(:user) { User.new(role: :waiter) }
    let(:sell_order) { create(:sell_order, :with_allocation, status: "delivering") }

    it "grants access for index" do
      expect(sell_order_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(sell_order_policy).to permit_action(:show)
    end

    it "grants access for create" do
      expect(sell_order_policy).to permit_action(:create)
    end

    it "grants access for update" do
      expect(sell_order_policy).not_to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(sell_order_policy).not_to permit_action(:destroy)
    end
  end

  context 'with kitchen_auxiliar and delivering sell_order' do
    let(:user) { User.new(role: :kitchen_auxiliar) }
    let(:sell_order) { create(:sell_order, :with_allocation, status: "delivering") }

    it "grants access for index" do
      expect(sell_order_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(sell_order_policy).to permit_action(:show)
    end

    it "denies access for create" do
      expect(sell_order_policy).not_to permit_action(:create)
    end

    it "denies access for update" do
      expect(sell_order_policy).not_to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(sell_order_policy).not_to permit_action(:destroy)
    end
  end

  context 'with cashier and delivering sell_order' do
    let(:user) { User.new(role: :cashier) }
    let(:sell_order) { create(:sell_order, :with_allocation, status: "delivering") }

    it "grants access for index" do
      expect(sell_order_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(sell_order_policy).to permit_action(:show)
    end

    it "denies access for create" do
      expect(sell_order_policy).not_to permit_action(:create)
    end

    it "denies access for update" do
      expect(sell_order_policy).to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(sell_order_policy).not_to permit_action(:destroy)
    end
  end

  context 'with admin and packed sell_order' do
    let(:user) { User.new(role: :admin) }
    let(:sell_order) { create(:sell_order, :with_allocation, status: "packed") }

    # it { is_expected.to permit_all_actions }
    it "grants access for index" do
      expect(sell_order_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(sell_order_policy).to permit_action(:show)
    end

    it "grants access for create" do
      expect(sell_order_policy).to permit_action(:create)
    end

    it "grants access for update" do
      expect(sell_order_policy).to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(sell_order_policy).not_to permit_action(:destroy)
    end
  end

  context 'with waiter and packed sell_order' do
    let(:user) { User.new(role: :waiter) }
    let(:sell_order) { create(:sell_order, :with_allocation, status: "packed") }

    # it { is_expected.to permit_all_actions }
    it "grants access for index" do
      expect(sell_order_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(sell_order_policy).to permit_action(:show)
    end

    it "grants access for create" do
      expect(sell_order_policy).to permit_action(:create)
    end

    it "grants access for update" do
      expect(sell_order_policy).to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(sell_order_policy).not_to permit_action(:destroy)
    end
  end

  context 'with kitchen_auxiliar and packed sell_order' do
    let(:user) { User.new(role: :kitchen_auxiliar) }
    let(:sell_order) { create(:sell_order, :with_allocation, status: "packed") }

    it "grants access for index" do
      expect(sell_order_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(sell_order_policy).to permit_action(:show)
    end

    it "denies access for create" do
      expect(sell_order_policy).not_to permit_action(:create)
    end

    it "denies access for update" do
      expect(sell_order_policy).not_to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(sell_order_policy).not_to permit_action(:destroy)
    end
  end

  context 'with cashier and packed sell_order' do
    let(:user) { User.new(role: :cashier) }
    let(:sell_order) { create(:sell_order, :with_allocation, status: "packed") }

    it "grants access for index" do
      expect(sell_order_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(sell_order_policy).to permit_action(:show)
    end

    it "denies access for create" do
      expect(sell_order_policy).not_to permit_action(:create)
    end

    it "denies access for update" do
      expect(sell_order_policy).to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(sell_order_policy).not_to permit_action(:destroy)
    end
  end

  context 'with admin and closed sell_order' do
    let(:user) { User.new(role: :admin) }
    let(:sell_order) { create(:sell_order, :with_allocation, status: "closed") }

    it "grants access for index" do
      expect(sell_order_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(sell_order_policy).to permit_action(:show)
    end

    it "grants access for create" do
      expect(sell_order_policy).to permit_action(:create)
    end

    it "grants access for update" do
      expect(sell_order_policy).to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(sell_order_policy).not_to permit_action(:destroy)
    end
  end

  context 'with waiter and closed sell_order' do
    let(:user) { User.new(role: :waiter) }
    let(:sell_order) { create(:sell_order, :with_allocation, status: "closed") }

    it "grants access for index" do
      expect(sell_order_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(sell_order_policy).to permit_action(:show)
    end

    it "grants access for create" do
      expect(sell_order_policy).to permit_action(:create)
    end

    it "grants access for update" do
      expect(sell_order_policy).not_to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(sell_order_policy).not_to permit_action(:destroy)
    end
  end

  context 'with kitchen_auxiliar and closed sell_order' do
    let(:user) { User.new(role: :kitchen_auxiliar) }
    let(:sell_order) { create(:sell_order, :with_allocation, status: "closed") }

    it "grants access for index" do
      expect(sell_order_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(sell_order_policy).to permit_action(:show)
    end

    it "denies access for create" do
      expect(sell_order_policy).not_to permit_action(:create)
    end

    it "denies access for update" do
      expect(sell_order_policy).not_to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(sell_order_policy).not_to permit_action(:destroy)
    end
  end

  context 'with cashier and closed sell_order' do
    let(:user) { User.new(role: :cashier) }
    let(:sell_order) { create(:sell_order, :with_allocation, status: "closed") }

    it "grants access for index" do
      expect(sell_order_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(sell_order_policy).to permit_action(:show)
    end

    it "denies access for create" do
      expect(sell_order_policy).not_to permit_action(:create)
    end

    it "denies access for update" do
      expect(sell_order_policy).to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(sell_order_policy).not_to permit_action(:destroy)
    end
  end

  context "when user is nil" do
      let(:user) { nil }
      let(:sell_order) { create(:sell_order, :with_allocation, status: "opened") }

      it { expect { sell_order_policy }.to raise_error(Pundit::NotAuthorizedError, "must be logged in") }
  end
end
