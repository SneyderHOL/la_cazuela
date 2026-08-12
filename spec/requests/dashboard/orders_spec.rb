require 'rails_helper'

RSpec.describe "Orders", type: :request do
  let(:user) do
    create(:user, email: "admin@example", password: "adminPass", password_confirmation: "adminPass")
  end

  describe "GET /dashboard/orders" do
    context "when user has already signin" do
      before { sign_in user }

      it "returns http success" do
        get "/dashboard/orders"
        expect(response).to have_http_status(:success)
      end

      # it "return valid content" do
      #   get "/dashboard/orders"
      #   expect(response.body).to include("Manage tables and delivery orders.")
      # end
    end

    context "when user has not signin" do
      it "returns http redirect" do
        get "/dashboard/orders"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        get "/dashboard/orders"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid flash alert message" do
        get "/dashboard/orders"
        follow_redirect!
        expect(response.body).to include("You need to sign in or sign up before continuing.")
      end
    end
  end
end
