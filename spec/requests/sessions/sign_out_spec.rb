require 'rails_helper'

RSpec.describe "Sign Out", type: :request do
  describe "DELETE /users/sign_out" do
    let(:user) do
      create(:user, email: "admin@example", password: "adminPass", password_confirmation: "adminPass")
    end

    before { sign_in user }

    it "returns http see other" do
      delete "/users/sign_out"
      expect(response).to have_http_status(:see_other)
    end
  end
end
