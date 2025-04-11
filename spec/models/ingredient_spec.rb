require 'rails_helper'

RSpec.describe Ingredient, type: :model do
  subject(:ingredient) { build(:ingredient) }

  describe "factory object" do
    it { is_expected.to be_valid }

    it 'name is not nil' do
      expect(ingredient.name).not_to be_nil
    end

    it "unit is not nil" do
      expect(ingredient.unit).not_to be_nil
    end

    it "stored_quantity is not nil" do
      expect(ingredient.stored_quantity).not_to be_nil
    end

    it "status is not nil" do
      expect(ingredient.status).not_to be_nil
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:recipes).through(:ingredient_recipes) }
    it { is_expected.to have_many(:ingredient_recipes) }
  end

  describe "validations" do
    it do
      expect(ingredient).to define_enum_for(:unit).with_values({
        mg: 1, ml: 0, one: 2
      }).backed_by_column_of_type(:integer)
    end

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:unit) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_numericality_of(:stored_quantity).is_greater_than_or_equal_to(0) }
  end

  describe "status transitions" do
    describe "when able is executed with unavailable" do
      before { ingredient.status = 'unavailable' }

      it do
        expect { ingredient.able }.to change(
          ingredient, :status).from("unavailable").to("available")
      end
    end

    describe "when able is executed with scarce" do
      before { ingredient.status = 'scarce' }

      it do
        expect { ingredient.able }.to change(
          ingredient, :status).from("scarce").to("available")
      end
    end

    describe "when disable is executed with available" do
      before { ingredient.status = 'available' }

      it do
        expect { ingredient.disable }.to change(
          ingredient, :status).from("available").to("unavailable")
      end
    end

    describe "when disable is executed with scarce" do
      before { ingredient.status = 'scarce' }

      it do
        expect { ingredient.disable }.to change(
          ingredient, :status).from("scarce").to("unavailable")
      end
    end

    describe "when running_out is executed with available" do
      before { ingredient.status = 'available' }

      it do
        expect { ingredient.running_out }.to change(
          ingredient, :status).from("available").to("scarce")
      end
    end
  end
end
