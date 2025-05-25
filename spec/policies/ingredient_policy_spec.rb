require 'rails_helper'

RSpec.describe IngredientPolicy, type: :policy do
  subject(:ingredient_policy) { described_class.new(user, ingredient) }

  let(:ingredient) { create(:ingredient) }

  context 'with admin' do
    let(:user) { User.new(role: :admin) }

    it { is_expected.to permit_all_actions }
  end

  context 'with waiter' do
    let(:user) { User.new(role: :waiter) }

    it "denies access for index" do
      expect(ingredient_policy).not_to permit_action(:index)
    end

    it "denies access for show" do
      expect(ingredient_policy).not_to permit_action(:show)
    end

    it "denies access for create" do
      expect(ingredient_policy).not_to permit_action(:create)
    end

    it "denies access for update" do
      expect(ingredient_policy).not_to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(ingredient_policy).not_to permit_action(:destroy)
    end
  end

  context 'with kitchen_auxiliar' do
    let(:user) { User.new(role: :kitchen_auxiliar) }

    it "denies access for index" do
      expect(ingredient_policy).not_to permit_action(:index)
    end

    it "denies access for show" do
      expect(ingredient_policy).not_to permit_action(:show)
    end

    it "denies access for create" do
      expect(ingredient_policy).not_to permit_action(:create)
    end

    it "denies access for update" do
      expect(ingredient_policy).not_to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(ingredient_policy).not_to permit_action(:destroy)
    end
  end

  context "when user is nil" do
      let(:user) { nil }

      it { expect { ingredient_policy }.to raise_error(Pundit::NotAuthorizedError, "must be logged in") }
  end
end
