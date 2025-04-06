RSpec.shared_examples "job enqueued for resource" do
  subject(:execute_job) { described_class.perform_later(resource) }

  before { ActiveJob::Base.queue_adapter = :test }

  it { expect { execute_job }.to have_enqueued_job }
end
