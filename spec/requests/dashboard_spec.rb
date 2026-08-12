require 'rails_helper'

RSpec.describe "Dashboard", type: :request do
  describe "GET /dashboard" do
    context "when user has already signin" do
      let(:user) do
        create(:user, email: "admin@example", password: "adminPass", password_confirmation: "adminPass")
      end

      before { sign_in user }

      it "returns http success" do
        get "/dashboard"
        expect(response).to have_http_status(:success)
      end

      it "return valid content" do
        get "/dashboard"
        expect(response.body).to include("Staff Dashboard")
      end
    end

    context "when user has not signin" do
      it "returns http redirect" do
        get "/dashboard"
        expect(response).to have_http_status(:found)
      end
    end
  end
end
