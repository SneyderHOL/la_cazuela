RSpec.shared_examples "job enqueued for order" do
  subject { described_class.perform_later(order) }

  before { ActiveJob::Base.queue_adapter = :test }

  it { expect { subject }.to have_enqueued_job }
end
