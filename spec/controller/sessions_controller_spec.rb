require "rails_helper"
include ApplicationHelper
include SessionsHelper

RSpec.shared_examples "a failed login" do
  it "should not create a session" do
    expect(session[:user_id]).to be_nil
  end

  it "should render new" do
    expect(response).to render_template :new
  end
end

RSpec.describe SessionsController, type: :controller do
  describe "POST #create" do
    context "fail when unactivated user" do
      before do
        user = FactoryBot.create :user
        post :create, params: {
          session: {
            email: user.email,
            password: user.password
          }
        }
      end

      it "show flash danger when unactivated user" do
        expect(flash[:warning]).to eq(I18n.t("sessions.create.unactivated_message"))
      end

      it_behaves_like "a failed login"
    end

    context "fail when email not found" do
      before do
        post :create, params: {
          session: {
            email: "wrong email@gmail.com",
            password: "123456"
          }
        }
      end

      it "show flash danger when email not found" do
        expect(flash[:danger]).to eq(I18n.t("sessions.create.failure_message"))
      end

      it_behaves_like "a failed login"
    end

    context "fail when password is wrong" do
      user = FactoryBot.create :activated_user
      before do
        post :create, params: {
          session: {
            email: user.email,
            password: "wrong password"
          }
        }
      end

      it "show flash danger when password is wrong" do
        expect(flash[:danger]).to eq(I18n.t("sessions.create.failure_message"))
      end

      it_behaves_like "a failed login"
    end

    context "success login when user is activated" do
      user = FactoryBot.create :activated_user
      before do
        post :create, params: {
          session: {
            email: user.email,
            password: user.password
          }
        }
        user.reload
      end

      it "create a session" do
        expect(session[:user_id]).to eq(user.id)
      end

      it "have session token in cookies" do
        expect(cookies[:session_token]).not_to be_nil
      end

      it "have user id in cookies" do
        expect(cookies[:user_id]).not_to be_nil
      end

      it "have session digest" do
        expect(user.session_digest).not_to be_nil
      end
    end
  end

  describe "DELETE #destroy" do
    context "success logout" do
      let(:user) {FactoryBot.create :activated_user}
      before do
        log_in user
        remember user
        delete :destroy
        user.reload
      end

      it "delete session digest in database" do
        expect(user.session_digest).to be_nil
      end

      it "delete user id in cookies" do
        expect(response.cookies[:user_id]).to be_nil
      end

      it "delete session token in cookies" do
        expect(response.cookies[:session_token]).to be_nil
      end

      it "assign nil to @user" do
        expect(assigns(:user)).to be_nil
      end

      it "redirect to root_url" do
        expect(response).to redirect_to root_url
      end
    end
  end
end
