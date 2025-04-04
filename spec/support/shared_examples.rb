RSpec.shared_examples "job enqueued for resource" do
  subject { described_class.perform_later(resource) }

  before { ActiveJob::Base.queue_adapter = :test }

  it { expect { subject }.to have_enqueued_job }
end
