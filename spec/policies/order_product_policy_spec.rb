require 'rails_helper'

RSpec.describe OrderProductPolicy, type: :policy do
  subject(:order_product_policy) { described_class.new(user, order_product) }

  context 'with admin and to_prepare order_product' do
    let(:user) { User.new(role: :admin) }
    let(:order_product) { create(:order_product, :with_associations, status: "to_prepare") }

    it { is_expected.to permit_all_actions }
  end

  context 'with waiter and to_prepare order_product' do
    let(:user) { User.new(role: :waiter) }
    let(:order_product) { create(:order_product, :with_associations, status: "to_prepare") }

    it { is_expected.to permit_all_actions }
  end

  context 'with kitchen_auxiliar and to_prepare order_product' do
    let(:user) { User.new(role: :kitchen_auxiliar) }
    let(:order_product) { create(:order_product, :with_associations, status: "to_prepare") }

    it "grants access for index" do
      expect(order_product_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(order_product_policy).to permit_action(:show)
    end

    it "denies access for create" do
      expect(order_product_policy).not_to permit_action(:create)
    end

    it "denies access for update" do
      expect(order_product_policy).not_to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(order_product_policy).not_to permit_action(:destroy)
    end
  end

  context 'with admin and preparing order_product' do
    let(:user) { User.new(role: :admin) }
    let(:order_product) { create(:order_product, :with_associations, status: "preparing") }

    it "grants access for index" do
      expect(order_product_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(order_product_policy).to permit_action(:show)
    end

    it "grants access for create" do
      expect(order_product_policy).to permit_action(:create)
    end

    it "grants access for update" do
      expect(order_product_policy).to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(order_product_policy).not_to permit_action(:destroy)
    end
  end

  context 'with waiter and preparing order_product' do
    let(:user) { User.new(role: :waiter) }
    let(:order_product) { create(:order_product, :with_associations, status: "preparing") }

    it "grants access for index" do
      expect(order_product_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(order_product_policy).to permit_action(:show)
    end

    it "grants access for create" do
      expect(order_product_policy).to permit_action(:create)
    end

    it "denies access for update" do
      expect(order_product_policy).not_to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(order_product_policy).not_to permit_action(:destroy)
    end
  end

  context 'with kitchen_auxiliar and preparing order_product' do
    let(:user) { User.new(role: :kitchen_auxiliar) }
    let(:order_product) { create(:order_product, :with_associations, status: "preparing") }

    it "grants access for index" do
      expect(order_product_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(order_product_policy).to permit_action(:show)
    end

    it "denies access for create" do
      expect(order_product_policy).not_to permit_action(:create)
    end

    it "grants access for update" do
      expect(order_product_policy).to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(order_product_policy).not_to permit_action(:destroy)
    end
  end

  context "for a nil user" do
      let(:user) { nil }
      let(:order_product) { create(:order_product, :with_associations, status: "to_prepare") }

      it { expect { order_product_policy }.to raise_error(Pundit::NotAuthorizedError, "must be logged in") }
  end
end
