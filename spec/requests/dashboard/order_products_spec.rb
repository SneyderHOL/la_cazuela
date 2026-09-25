require 'rails_helper'

RSpec.describe "OrderProduct", type: :request do
  let(:order_product) { create(:order_product, :with_associations) }
  let(:user) do
    create(:user, email: "admin@example", password: "adminPass", password_confirmation: "adminPass")
  end

  describe "GET /dashboard/preparations" do
    context "when user has already signin" do
      before { sign_in user }

      it "returns http success" do
        get "/dashboard/preparations"
        expect(response).to have_http_status(:success)
      end

      it "return valid content" do
        get "/dashboard/preparations"
        expect(response.body).to include("Manage products that are currently waiting to be prepared.")
      end
    end

    context "when user has not signin" do
      it "returns http redirect" do
        get "/dashboard/preparations"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        get "/dashboard/preparations"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid flash alert message" do
        get "/dashboard/preparations"
        follow_redirect!
        expect(response.body).to include("You need to sign in or sign up before continuing.")
      end
    end
  end

  describe "PATCH /dashboard/preparations/:id/cook" do
    context "when user has already signin and performs action" do
      before do
        order_product.ready_to_cook!
        sign_in user
      end

      it "returns http redirect" do
        patch "/dashboard/preparations/#{order_product.id}/cook"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        patch "/dashboard/preparations/#{order_product.id}/cook"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid flash notice message" do
        patch "/dashboard/preparations/#{order_product.id}/cook"
        follow_redirect!
        expect(response.body).to include("Preparation is being cook.")
      end
    end

    context "when user has already signin and is unable to perform action due to insufficient stock error" do
      let(:consumption_service_instance) { instance_double(Inventory::ConsumeOrderProduct) }

      before do
        allow(Inventory::ConsumeOrderProduct).to receive(:new).and_return(consumption_service_instance)
        allow(consumption_service_instance).to receive(:call) { raise Inventory::ConsumeOrderProduct::InsufficientStockError, "Salt has insufficient stock" }
        order_product.ready_to_cook!
        sign_in user
      end

      it "returns http unprocessable content" do
        patch "/dashboard/preparations/#{order_product.id}/cook"
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "return valid flash alert message" do
        patch "/dashboard/preparations/#{order_product.id}/cook"
        expect(response.body).to include("Unable to start preparation: Salt has insufficient stock")
      end
    end

    context "when user has already signin and is unable to perform action due to transition error" do
      before do
        order_product
        sign_in user
      end

      it "returns http unprocessable content" do
        patch "/dashboard/preparations/#{order_product.id}/cook"
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "return valid flash alert message" do
        patch "/dashboard/preparations/#{order_product.id}/cook"
        expect(response.body).to include("Unable to perform that action.")
      end
    end

    context "when user has not signin" do
      before { order_product }

      it "returns http redirect" do
        patch "/dashboard/preparations/#{order_product.id}/cook"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        patch "/dashboard/preparations/#{order_product.id}/cook"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid flash alert message" do
        patch "/dashboard/preparations/#{order_product.id}/cook"
        follow_redirect!
        expect(response.body).to include("You need to sign in or sign up before continuing.")
      end
    end
  end

  describe "PATCH /dashboard/preparations/:id/complete" do
    context "when user has already signin and performs action" do
      before do
        order_product.ready_to_cook! && order_product.cook!
        sign_in user
      end

      it "returns http redirect" do
        patch "/dashboard/preparations/#{order_product.id}/complete"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        patch "/dashboard/preparations/#{order_product.id}/complete"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid flash notice message" do
        patch "/dashboard/preparations/#{order_product.id}/complete"
        follow_redirect!
        expect(response.body).to include("Preparation is done.")
      end
    end

    context "when user has already signin and is unable to perform action" do
      before do
        order_product
        sign_in user
      end

      it "returns http unprocessable content" do
        patch "/dashboard/preparations/#{order_product.id}/complete"
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "return valid flash alert message" do
        patch "/dashboard/preparations/#{order_product.id}/complete"
        expect(response.body).to include("Unable to perform that action.")
      end
    end

    context "when user has not signin" do
      before { order_product }

      it "returns http redirect" do
        patch "/dashboard/preparations/#{order_product.id}/complete"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        patch "/dashboard/preparations/#{order_product.id}/complete"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid flash alert message" do
        patch "/dashboard/preparations/#{order_product.id}/complete"
        follow_redirect!
        expect(response.body).to include("You need to sign in or sign up before continuing.")
      end
    end
  end

  describe "DELETE /dashboard/preparations/:id" do
    context "when user has already signin and performs action" do
      let(:order_product2) { create(:order_product, :with_product, order: order_product.order) }

      before do
        order_product2
        sign_in user
      end

      it "returns http redirect" do
        delete "/dashboard/preparations/#{order_product.id}"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        delete "/dashboard/preparations/#{order_product.id}"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid flash notice message" do
        delete "/dashboard/preparations/#{order_product.id}"
        follow_redirect!
        expect(response.body).to include("Preparation was destroyed successfully.")
      end
    end

    context "when user has already signin and is unable to perform action" do
      before do
        order_product.update(status: :preparing)
        sign_in user
      end

      it "returns http unprocessable content" do
        delete "/dashboard/preparations/#{order_product.id}"
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "return valid flash alert message" do
        delete "/dashboard/preparations/#{order_product.id}"
        expect(response.body).to include("This record cannot be deleted because has already started or completed")
      end
    end

    context "when user has not signin" do
      before { order_product }

      it "returns http redirect" do
        delete "/dashboard/preparations/#{order_product.id}"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        delete "/dashboard/preparations/#{order_product.id}"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid flash alert message" do
        delete "/dashboard/preparations/#{order_product.id}"
        follow_redirect!
        expect(response.body).to include("You need to sign in or sign up before continuing.")
      end
    end
  end
end
