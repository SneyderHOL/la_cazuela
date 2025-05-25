require 'rails_helper'

RSpec.describe ProductPolicy, type: :policy do
  subject(:product_policy) { described_class.new(user, product) }

  let(:product) { create(:product) }

  context 'with admin' do
    let(:user) { User.new(role: :admin) }

    it { is_expected.to permit_all_actions }
  end

  context 'with waiter' do
    let(:user) { User.new(role: :waiter) }

    it "grants access for index" do
      expect(product_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(product_policy).to permit_action(:show)
    end

    it "denies access for create" do
      expect(product_policy).not_to permit_action(:create)
    end

    it "denies access for update" do
      expect(product_policy).not_to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(product_policy).not_to permit_action(:destroy)
    end
  end

  context 'with kitchen_auxiliar' do
    let(:user) { User.new(role: :kitchen_auxiliar) }

    it "grants access for index" do
      expect(product_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(product_policy).to permit_action(:show)
    end

    it "denies access for create" do
      expect(product_policy).not_to permit_action(:create)
    end

    it "denies access for update" do
      expect(product_policy).not_to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(product_policy).not_to permit_action(:destroy)
    end
  end

  context "for a nil user" do
      let(:user) { nil }

      it { expect { product_policy }.to raise_error(Pundit::NotAuthorizedError, "must be logged in") }
  end
end
