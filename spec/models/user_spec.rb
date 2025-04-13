require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe "factory object" do
    it { is_expected.to be_valid }

    it "name is not nil" do
      expect(user.name).not_to be_nil
    end

    it "role is not nil" do
      expect(user.role).not_to be_nil
    end

    it "email is not nil" do
      expect(user.email).not_to be_nil
    end

    it "password is not nil" do
      expect(user.password).not_to be_nil
    end

    it "active is not nil" do
      expect(user.active).not_to be_nil
    end
  end

  describe "validations" do
    it do
      expect(user).to define_enum_for(:role).with_values({
        waiter: "waiter", admin: "admin"
      }).backed_by_column_of_type(:string)
    end

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to validate_exclusion_of(:active).in_array([ nil ]) }

    context "when format is invalid for email" do
      it { is_expected.not_to allow_value("test").for(:email) }
      it { is_expected.not_to allow_value("test@").for(:email) }
      it { is_expected.not_to allow_value("@test").for(:email) }
    end

    context "when format is valid for email" do
      it { is_expected.to allow_value("test@test.com").for(:email) }
    end
  end
end
