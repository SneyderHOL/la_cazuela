require 'rails_helper'

RSpec.describe Order, type: :model do
  subject(:order) { build(:order) }

  describe "factory object" do
    it 'is valid' do
      expect(order).to be_valid
      expect(order.status).not_to be_nil
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:status) }
  end

  describe "status transitions" do
    describe 'process' do
      before { order.status = 'opened' }
      it do
        expect { order.process }.to change(
          order, :status).from("opened").to("processing")
      end
    end

    describe 'complete' do
      before { order.status = 'processing' }
      it do
        expect { order.complete }.to change(
          order, :status).from("processing").to("completed")
      end
    end

    describe 'close' do
      before { order.status = 'completed' }
      it do
        expect { order.close }.to change(
          order, :status).from("completed").to("closed")
      end
    end
  end
end
