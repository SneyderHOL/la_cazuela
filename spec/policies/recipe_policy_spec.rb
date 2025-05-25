require 'rails_helper'

RSpec.describe RecipePolicy, type: :policy do
  subject(:recipe_policy) { described_class.new(user, recipe) }

  let(:recipe) { create(:recipe) }

  context 'with admin' do
    let(:user) { User.new(role: :admin) }

    it { is_expected.to permit_all_actions }
  end

  context 'with waiter' do
    let(:user) { User.new(role: :waiter) }

    it "denies access for index" do
      expect(recipe_policy).not_to permit_action(:index)
    end

    it "denies access for show" do
      expect(recipe_policy).not_to permit_action(:show)
    end

    it "denies access for create" do
      expect(recipe_policy).not_to permit_action(:create)
    end

    it "denies access for update" do
      expect(recipe_policy).not_to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(recipe_policy).not_to permit_action(:destroy)
    end
  end

  context 'with kitchen_auxiliar' do
    let(:user) { User.new(role: :kitchen_auxiliar) }

    it "denies access for index" do
      expect(recipe_policy).not_to permit_action(:index)
    end

    it "denies access for show" do
      expect(recipe_policy).not_to permit_action(:show)
    end

    it "denies access for create" do
      expect(recipe_policy).not_to permit_action(:create)
    end

    it "denies access for update" do
      expect(recipe_policy).not_to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(recipe_policy).not_to permit_action(:destroy)
    end
  end

  context "for a nil user" do
      let(:user) { nil }

      it { expect { recipe_policy }.to raise_error(Pundit::NotAuthorizedError, "must be logged in") }
  end
end
