require 'rails_helper'

RSpec.describe AllocationPolicy, type: :policy do
  subject(:allocation_policy) { described_class.new(user, allocation) }

  let(:allocation) { create(:allocation) }


  context 'with admin and inactive allocation' do
    let(:user) { User.new(role: :admin) }
    let(:allocation) { create(:allocation, active: false) }

    it { is_expected.to permit_all_actions }
  end

  context 'with waiter and inactive allocation' do
    let(:user) { User.new(role: :waiter) }
    let(:allocation) { create(:allocation, active: false) }

    it "denies access for index" do
      expect(allocation_policy).not_to permit_action(:index)
    end

    it "denies access for show" do
      expect(allocation_policy).not_to permit_action(:show)
    end

    it "denies access for create" do
      expect(allocation_policy).not_to permit_action(:create)
    end

    it "denies access for update" do
      expect(allocation_policy).not_to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(allocation_policy).not_to permit_action(:destroy)
    end
  end

  context 'with kitchen_auxiliar and inactive allocation' do
    let(:user) { User.new(role: :kitchen_auxiliar) }
    let(:allocation) { create(:allocation, active: false) }

    it "denies access for index" do
      expect(allocation_policy).not_to permit_action(:index)
    end

    it "denies access for show" do
      expect(allocation_policy).not_to permit_action(:show)
    end

    it "denies access for create" do
      expect(allocation_policy).not_to permit_action(:create)
    end

    it "denies access for update" do
      expect(allocation_policy).not_to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(allocation_policy).not_to permit_action(:destroy)
    end
  end

  context 'with admin and active allocation' do
    let(:user) { User.new(role: :admin) }
    let(:allocation) { create(:allocation, active: true) }

    it { is_expected.to permit_all_actions }
  end

  context 'with waiter and active allocation' do
    let(:user) { User.new(role: :waiter) }
    let(:allocation) { create(:allocation, active: true) }

    it "grants access for index" do
      expect(allocation_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(allocation_policy).to permit_action(:show)
    end

    it "denies access for create" do
      expect(allocation_policy).not_to permit_action(:create)
    end

    it "grants access for update" do
      expect(allocation_policy).to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(allocation_policy).not_to permit_action(:destroy)
    end
  end

  context 'with kitchen_auxiliar and active allocation' do
    let(:user) { User.new(role: :kitchen_auxiliar) }
    let(:allocation) { create(:allocation, active: true) }

    it "grants access for index" do
      expect(allocation_policy).to permit_action(:index)
    end

    it "grants access for show" do
      expect(allocation_policy).to permit_action(:show)
    end

    it "denies access for create" do
      expect(allocation_policy).not_to permit_action(:create)
    end

    it "denies access for update" do
      expect(allocation_policy).not_to permit_action(:update)
    end

    it "denies access for destroy" do
      expect(allocation_policy).not_to permit_action(:destroy)
    end
  end

  context "for a nil user" do
      let(:user) { nil }

      it { expect { allocation_policy }.to raise_error(Pundit::NotAuthorizedError, "must be logged in") }
  end
end
