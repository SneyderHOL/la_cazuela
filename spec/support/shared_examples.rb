RSpec.shared_examples "job enqueued for resource" do
  subject(:execute_job) { described_class.perform_later(resource) }

  before { ActiveJob::Base.queue_adapter = :test }

  it { expect { execute_job }.to have_enqueued_job }
end

RSpec.shared_examples "calls the CreateInventoryTransactionsJob" do
  it { expect(CreateInventoryTransactionsJob).to have_received(:perform_later) }
end

RSpec.shared_examples "not call the CreateInventoryTransactionsJob" do
  it { expect(CreateInventoryTransactionsJob).not_to have_received(:perform_later) }
end

RSpec.shared_examples "active scoping" do |resource, traits = nil|
  describe "#active" do
    let(:inactive_resources) { create_list(resource, 3, *Array(traits)) }
    let(:active_resources) { create_list(resource, 2, :with_active_on, *Array(traits)) }
    let(:scope_result) { described_class.active }

    before do
      inactive_resources
      active_resources
    end

    it { expect(scope_result.count).to be(2) }
    it { expect(scope_result.first).to eql(active_resources.first) }
    it { expect(scope_result.last).to eql(active_resources.last) }
  end
end

RSpec.shared_examples "inactive scoping" do |resource, traits = nil|
  describe "#inactive" do
    let(:inactive_resources) { create_list(resource, 3, *Array(traits)) }
    let(:active_resources) { create_list(resource, 2, :with_active_on, *Array(traits)) }
    let(:scope_result) { described_class.inactive }

    before do
      inactive_resources
      active_resources
    end

    it { expect(scope_result.count).to be(3) }
    it { expect(scope_result.first).to eql(inactive_resources.first) }
    it { expect(scope_result.second).to eql(inactive_resources.second) }
    it { expect(scope_result.last).to eql(inactive_resources.last) }
  end
end

RSpec.shared_examples "current_sales result for sell_orders" do
  it "retrieves the corresponding sell_orders" do
    specific_date = saturday + 3.hours

    travel_to specific_date do
      expect(described_class.current_sales(status, kinds).count).to eq(3)
    end
  end

  it "retrieves the corresponding sell_orders status" do
    specific_date = saturday + 3.hours

    travel_to specific_date do
      expect(described_class.current_sales(status, kinds).pluck(:status).uniq).to eq([ status.to_s ])
    end
  end

  it "retrieves the corresponding sell_orders creation day" do
    specific_date = saturday + 3.hours

    travel_to specific_date do
      expect(described_class.current_sales(status, kinds).pluck(:created_at).map(&:day).uniq).to eq([ saturday.day ])
    end
  end
end
