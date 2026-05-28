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
