require 'rails_helper'

RSpec.describe "Allocations", type: :request do
  let(:allocation) { create(:allocation, :with_active_on) }
  let(:user) do
    create(:user, email: "admin@example", password: "adminPass", password_confirmation: "adminPass")
  end

  describe "GET /dashboard/allocations" do
    context "when user has already signin" do
      before { sign_in user }

      it "returns http success" do
        get "/dashboard/allocations"
        expect(response).to have_http_status(:success)
      end

      it "return valid content" do
        get "/dashboard/allocations"
        expect(response.body).to include("Manage tables and delivery allocations.")
      end
    end

    context "when user has not signin" do
      it "returns http redirect" do
        get "/dashboard/allocations"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        get "/dashboard/allocations"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid flash alert message" do
        get "/dashboard/allocations"
        follow_redirect!
        expect(response.body).to include("You need to sign in or sign up before continuing.")
      end
    end
  end

  describe "GET /dashboard/allocations/:id" do
    context "when user has already signin" do
      before do
        allocation
        sign_in user
      end

      it "returns http success" do
        get "/dashboard/allocations/#{allocation.id}"
        expect(response).to have_http_status(:success)
      end

      it "return valid content" do
        get "/dashboard/allocations/#{allocation.id}"
        expect(response.body).to include("This table is ready to receive a new order.")
      end
    end

    context "when user has not signin" do
      before { allocation }

      it "returns http redirect" do
        get "/dashboard/allocations/#{allocation.id}"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        get "/dashboard/allocations/#{allocation.id}"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid flash alert message" do
        get "/dashboard/allocations/#{allocation.id}"
        follow_redirect!
        expect(response.body).to include("You need to sign in or sign up before continuing.")
      end
    end
  end

  describe "POST /dashboard/allocations/:id/free" do
    context "when user has already signin and performs action" do
      before do
        allocation
        sign_in user
      end

      it "returns http redirect" do
        post "/dashboard/allocations/#{allocation.id}/free"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        post "/dashboard/allocations/#{allocation.id}/free"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid content" do
        post "/dashboard/allocations/#{allocation.id}/free"
        follow_redirect!
        expect(response.body).to include("Allocation was set to available.")
      end
    end

    context "when user has already signin and is unable to perform action" do
      let(:sell_order) { create(:sell_order, allocation:) }

      before do
        allocation.update(status: :busy)
        sell_order
        sign_in user
      end

      it "returns http unprocessable content" do
        post "/dashboard/allocations/#{allocation.id}/free"
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "return valid flash alert message" do
        post "/dashboard/allocations/#{allocation.id}/free"
        expect(response.body).to include("Unable to perform that action.")
      end
    end

    context "when user has not signin" do
      before { allocation }

      it "returns http redirect" do
        post "/dashboard/allocations/#{allocation.id}/free"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        post "/dashboard/allocations/#{allocation.id}/free"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid flash alert message" do
        post "/dashboard/allocations/#{allocation.id}/free"
        follow_redirect!
        expect(response.body).to include("You need to sign in or sign up before continuing.")
      end
    end
  end

  describe "POST /dashboard/allocations/:id/clean" do
    context "when user has already signin and performs action" do
      before do
        allocation
        sign_in user
      end

      it "returns http redirect" do
        post "/dashboard/allocations/#{allocation.id}/clean"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        post "/dashboard/allocations/#{allocation.id}/clean"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid content" do
        post "/dashboard/allocations/#{allocation.id}/clean"
        follow_redirect!
        expect(response.body).to include("Allocation was set to cleaning.")
      end
    end

    context "when user has already signin and is unable to perform action" do
      let(:sell_order) { create(:sell_order, allocation:) }

      before do
        allocation.update(status: :busy)
        sell_order
        sign_in user
      end

      it "returns http unprocessable content" do
        post "/dashboard/allocations/#{allocation.id}/clean"
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "return valid flash alert message" do
        post "/dashboard/allocations/#{allocation.id}/clean"
        expect(response.body).to include("Unable to perform that action.")
      end
    end

    context "when user has not signin" do
      before { allocation }

      it "returns http redirect" do
        post "/dashboard/allocations/#{allocation.id}/clean"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        post "/dashboard/allocations/#{allocation.id}/clean"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid flash alert message" do
        post "/dashboard/allocations/#{allocation.id}/clean"
        follow_redirect!
        expect(response.body).to include("You need to sign in or sign up before continuing.")
      end
    end
  end

  describe "POST /dashboard/allocations/:id/reserve" do
    context "when user has already signin and performs action" do
      before do
        allocation
        sign_in user
      end

      it "returns http redirect" do
        post "/dashboard/allocations/#{allocation.id}/reserve"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        post "/dashboard/allocations/#{allocation.id}/reserve"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid content" do
        post "/dashboard/allocations/#{allocation.id}/reserve"
        follow_redirect!
        expect(response.body).to include("Allocation was set to on hold.")
      end
    end

    context "when user has already signin and is unable to perform action" do
      before do
        allocation.update(status: :busy)
        sign_in user
      end

      it "returns http unprocessable content" do
        post "/dashboard/allocations/#{allocation.id}/reserve"
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "return valid flash alert message" do
        post "/dashboard/allocations/#{allocation.id}/reserve"
        expect(response.body).to include("Unable to perform that action.")
      end
    end

    context "when user has not signin" do
      before { allocation }

      it "returns http redirect" do
        post "/dashboard/allocations/#{allocation.id}/reserve"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        post "/dashboard/allocations/#{allocation.id}/reserve"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid flash alert message" do
        post "/dashboard/allocations/#{allocation.id}/reserve"
        follow_redirect!
        expect(response.body).to include("You need to sign in or sign up before continuing.")
      end
    end
  end
end
