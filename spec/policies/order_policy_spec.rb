require 'rails_helper'

RSpec.describe OrderPolicy, type: :policy do
  subject(:order_policy) { described_class.new(user, order) }

  context 'with admin and opened order' do
    let(:user) { User.new(role: :admin) }
    let(:order) { create(:order, :with_sell_order, status: "opened") }

    it { is_expected.to permit_all_actions }
  end

  context 'with waiter and opened order' do
    let(:user) { User.new(role: :waiter) }
    let(:order) { create(:order, :with_sell_order, status: "opened") }

    it { is_expected.to permit_all_actions }
  end

  context 'with kitchen_auxiliar and opened order' do
    let(:user) { User.new(role: :kitchen_auxiliar) }
    let(:order) { create(:order, :with_sell_order, status: "opened") }

    it "grants access for index" do
      expect(order_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(order_policy).to permit_action(:show)
    end

    it "denies access for create" do
      expect(order_policy).not_to permit_action(:create)
    end

    it "denies access for update" do
      expect(order_policy).not_to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(order_policy).not_to permit_action(:destroy)
    end
  end

  context 'with cashier and opened order' do
    let(:user) { User.new(role: :cashier) }
    let(:order) { create(:order, :with_sell_order, status: "opened") }

    it "grants access for index" do
      expect(order_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(order_policy).to permit_action(:show)
    end

    it "denies access for create" do
      expect(order_policy).not_to permit_action(:create)
    end

    it "denies access for update" do
      expect(order_policy).not_to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(order_policy).not_to permit_action(:destroy)
    end
  end

  context 'with admin and processing order' do
    let(:user) { User.new(role: :admin) }
    let(:order) { create(:order, :with_sell_order, status: "processing") }

    it "grants access for index" do
      expect(order_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(order_policy).to permit_action(:show)
    end

    it "grants access for create" do
      expect(order_policy).to permit_action(:create)
    end

    it "grants access for update" do
      expect(order_policy).to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(order_policy).not_to permit_action(:destroy)
    end
  end

  context 'with waiter and processing order' do
    let(:user) { User.new(role: :waiter) }
    let(:order) { create(:order, :with_sell_order, status: "processing") }

    it "grants access for index" do
      expect(order_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(order_policy).to permit_action(:show)
    end

    it "grants access for create" do
      expect(order_policy).to permit_action(:create)
    end

    it "grants access for update" do
      expect(order_policy).to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(order_policy).not_to permit_action(:destroy)
    end
  end

  context 'with kitchen_auxiliar and processing order' do
    let(:user) { User.new(role: :kitchen_auxiliar) }
    let(:order) { create(:order, :with_sell_order, status: "processing") }

    it "grants access for index" do
      expect(order_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(order_policy).to permit_action(:show)
    end

    it "denies access for create" do
      expect(order_policy).not_to permit_action(:create)
    end

    it "denies access for update" do
      expect(order_policy).not_to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(order_policy).not_to permit_action(:destroy)
    end
  end

  context 'with cashier and processing order' do
    let(:user) { User.new(role: :cashier) }
    let(:order) { create(:order, :with_sell_order, status: "processing") }

    it "grants access for index" do
      expect(order_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(order_policy).to permit_action(:show)
    end

    it "denies access for create" do
      expect(order_policy).not_to permit_action(:create)
    end

    it "denies access for update" do
      expect(order_policy).not_to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(order_policy).not_to permit_action(:destroy)
    end
  end

  context 'with admin and packed order' do
    let(:user) { User.new(role: :admin) }
    let(:order) { create(:order, :with_sell_order, status: "packed") }

    # it { is_expected.to permit_all_actions }
    it "grants access for index" do
      expect(order_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(order_policy).to permit_action(:show)
    end

    it "grants access for create" do
      expect(order_policy).to permit_action(:create)
    end

    it "grants access for update" do
      expect(order_policy).to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(order_policy).not_to permit_action(:destroy)
    end
  end

  context 'with waiter and packed order' do
    let(:user) { User.new(role: :waiter) }
    let(:order) { create(:order, :with_sell_order, status: "packed") }

    # it { is_expected.to permit_all_actions }
    it "grants access for index" do
      expect(order_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(order_policy).to permit_action(:show)
    end

    it "grants access for create" do
      expect(order_policy).to permit_action(:create)
    end

    it "grants access for update" do
      expect(order_policy).to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(order_policy).not_to permit_action(:destroy)
    end
  end

  context 'with kitchen_auxiliar and packed order' do
    let(:user) { User.new(role: :kitchen_auxiliar) }
    let(:order) { create(:order, :with_sell_order, status: "packed") }

    it "grants access for index" do
      expect(order_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(order_policy).to permit_action(:show)
    end

    it "denies access for create" do
      expect(order_policy).not_to permit_action(:create)
    end

    it "denies access for update" do
      expect(order_policy).not_to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(order_policy).not_to permit_action(:destroy)
    end
  end

  context 'with cashier and packed order' do
    let(:user) { User.new(role: :cashier) }
    let(:order) { create(:order, :with_sell_order, status: "packed") }

    it "grants access for index" do
      expect(order_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(order_policy).to permit_action(:show)
    end

    it "denies access for create" do
      expect(order_policy).not_to permit_action(:create)
    end

    it "denies access for update" do
      expect(order_policy).not_to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(order_policy).not_to permit_action(:destroy)
    end
  end

  context 'with admin and completed order' do
    let(:user) { User.new(role: :admin) }
    let(:order) { create(:order, :with_sell_order, status: "completed") }

    it "grants access for index" do
      expect(order_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(order_policy).to permit_action(:show)
    end

    it "grants access for create" do
      expect(order_policy).to permit_action(:create)
    end

    it "grants access for update" do
      expect(order_policy).to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(order_policy).not_to permit_action(:destroy)
    end
  end

  context 'with waiter and completed order' do
    let(:user) { User.new(role: :waiter) }
    let(:order) { create(:order, :with_sell_order, status: "completed") }

    it "grants access for index" do
      expect(order_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(order_policy).to permit_action(:show)
    end

    it "grants access for create" do
      expect(order_policy).to permit_action(:create)
    end

    it "grants access for update" do
      expect(order_policy).to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(order_policy).not_to permit_action(:destroy)
    end
  end

  context 'with kitchen_auxiliar and completed order' do
    let(:user) { User.new(role: :kitchen_auxiliar) }
    let(:order) { create(:order, :with_sell_order, status: "completed") }

    it "grants access for index" do
      expect(order_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(order_policy).to permit_action(:show)
    end

    it "denies access for create" do
      expect(order_policy).not_to permit_action(:create)
    end

    it "denies access for update" do
      expect(order_policy).not_to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(order_policy).not_to permit_action(:destroy)
    end
  end

  context 'with cashier and completed order' do
    let(:user) { User.new(role: :cashier) }
    let(:order) { create(:order, :with_sell_order, status: "completed") }

    it "grants access for index" do
      expect(order_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(order_policy).to permit_action(:show)
    end

    it "denies access for create" do
      expect(order_policy).not_to permit_action(:create)
    end

    it "denies access for update" do
      expect(order_policy).not_to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(order_policy).not_to permit_action(:destroy)
    end
  end

  context "when user is nil" do
      let(:user) { nil }
      let(:order) { create(:order, :with_sell_order, status: "opened") }

      it { expect { order_policy }.to raise_error(Pundit::NotAuthorizedError, "must be logged in") }
  end
end
