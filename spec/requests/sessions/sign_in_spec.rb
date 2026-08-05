require 'rails_helper'

RSpec.describe "Sign In", type: :request do
  describe "GET /users/sign_in" do
    it "returns http success" do
      get "/users/sign_in"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /users/sign_in" do
    before do
      create(:user, email: "admin@example", password: "adminPass", password_confirmation: "adminPass")
    end

    context "when login is success" do
      let(:params) { { user: { email: "admin@example", password: "adminPass" } } }

      it "returns http see other" do
        post "/users/sign_in", params: params
        expect(response).to have_http_status(:see_other)
      end
    end

    context "when login fail" do
      let(:params) { { user: { email: "admin@example", password: "admin" } } }

      it "returns http unprocessable content" do
        post "/users/sign_in", params: params
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "return valid flash alert message" do
        post "/users/sign_in", params: params
        expect(response.body).to include("Invalid email or password.")
      end
    end
  end
end
