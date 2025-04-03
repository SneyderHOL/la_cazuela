require 'rails_helper'

RSpec.describe Recipe, type: :model do
  subject(:recipe) { build(:recipe) }

  describe "factory object" do
    it 'is valid' do
      expect(recipe).to be_valid
      expect(recipe.name).not_to be_nil
      expect(recipe.status).not_to be_nil
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe "status transitions" do
    describe 'approve' do
      before { recipe.status = 'declined' }
      it do
        expect { recipe.approve }.to change(
          recipe, :status).from("declined").to("approved")
      end
    end

    describe 'decline' do
      before { recipe.status = 'approved' }
      it do
        expect { recipe.decline }.to change(
          recipe, :status).from("approved").to("declined")
      end
    end
  end
end
