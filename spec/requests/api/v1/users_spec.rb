require "rails_helper"

RSpec.describe "Api::V1::Users", type: :request do
  describe "POST /api/v1/users" do
    context "正常系" do
      it "正しいパラメーターでPOSTすると201が返ること" do
        params = { user: attributes_for(:user) }
        post "/api/v1/users", params: params
        expect(response).to have_http_status(201)
      end

      it "正しいパラメーターでPOSTするとUser.countが1増えること" do
        params = { user: attributes_for(:user) }
        expect {
          post "/api/v1/users", params: params
      }.to change(User, :count).by(1)
      end
    end

    context "異常系" do
      it "nicknameが空の場合422が返ること" do
        params = { user: attributes_for(:user, nickname: "") }
        post "/api/v1/users", params: params
        expect(response).to have_http_status(422)
      end

      it "メールアドレスが空の場合422が返ること" do
        params = { user: attributes_for(:user, email: "") }
        post "/api/v1/users", params: params
        expect(response).to have_http_status(422)
      end

      it "メールアドレスが重複している場合422が返ること" do
        create(:user, email: "test@example.com")
        params = { user: attributes_for(:user, email: "test@example.com") }
        post "/api/v1/users", params: params
        expect(response).to have_http_status(422)
      end

        it "メールアドレスが大文字小文字違いで重複している場合422が返ること" do
          create(:user, email: "test@example.com")
          params = { user: attributes_for(:user, email: "TEST@EXAMPLE.COM") }
          post "/api/v1/users", params: params
          expect(response).to have_http_status(422)
        end

        it "メールアドレスの形式が不正な場合422が返ること" do
          params = { user: attributes_for(:user, email: "invalid-email") }
          post "/api/v1/users", params: params
          expect(response).to have_http_status(422)
        end

          it "パスワードが空の場合422が返ること" do
            params = { user: attributes_for(:user, password: "") }
            post "/api/v1/users", params: params
            expect(response).to have_http_status(422)
          end
    end

    context "境界値" do
        it "nicknameが30文字の場合201が返ること" do
          params = { user: attributes_for(:user, nickname: "a" * 30) }
          post "/api/v1/users", params: params
          expect(response).to have_http_status(201)
        end

          it "nicknameが31文字の場合422が返ること" do
            params = { user: attributes_for(:user, nickname: "a" * 31) }
            post "/api/v1/users", params: params
            expect(response).to have_http_status(422)
          end

            it "パスワードが7文字の場合422が返ること" do
              params = { user: attributes_for(:user, password: "a" * 7) }
              post "/api/v1/users", params: params
              expect(response).to have_http_status(422)
            end

              it "パスワードが8文字の場合201が返ること" do
                params = { user: attributes_for(:user, password: "a" * 8) }
                post "/api/v1/users", params: params
                expect(response).to have_http_status(201)
              end
    end
  end

  describe "PATCH /api/v1/users/:id" do
    context "正常系" do
      it "nicknameが更新されること" do
        user = create(:user)
        new_params = { user: { nickname: "新しいニックネーム" } }
        patch "/api/v1/users/#{user.id}", params: new_params
        expect(response).to have_http_status(200)
        expect(user.reload.nickname).to eq("新しいニックネーム")
      end
    end

    context "異常系" do
      let (:user) { create(:user) }
      it "空文字でnicknameにPATCHリクエストを送ると422が返ること" do
        new_params = { user: { nickname: "" } }
        patch "/api/v1/users/#{user.id}", params: new_params
        expect(response).to have_http_status(422)
      end

      it "空文字でemailにPATCHリクエストを送ると422が返ること" do
        new_params = { user: { email: "" } }
        patch "/api/v1/users/#{user.id}", params: new_params
        expect(response).to have_http_status(422)
      end

      it "nullでnicknameにPATCHリクエストを送ると422が返ること" do
        new_params = { user: { nickname: nil } }
        patch "/api/v1/users/#{user.id}", params: new_params
        expect(response).to have_http_status(422)
      end

      it "nullでemailにPATCHリクエストを送ると422が返ること" do
        new_params = { user: { email: nil } }
        patch "/api/v1/users/#{user.id}", params: new_params
        expect(response).to have_http_status(422)
      end

      it "Eメールの形式に則っていないパラメータではEメールが更新できず422が返ること" do
        new_params = { user: { email: "invalid-email" } }
        patch "/api/v1/users/#{user.id}", params: new_params
        expect(response).to have_http_status(422)
      end

      it "存在しないユーザーIDにPATCHリクエストを送ると404が返ること" do
        new_params = { user: { nickname: "新しいニックネーム" } }
        patch "/api/v1/users/999", params: new_params
        expect(response).to have_http_status(404)
      end
    end

    context "境界値" do
      let(:user) { create(:user) }
      it "nicknameが30文字の場合200が返ること" do
        new_params = { user: { nickname: "a" * 30 } }
        patch "/api/v1/users/#{user.id}", params: new_params
        expect(response).to have_http_status(200)
      end

      it "nicknameが31文字の場合422が返ること" do
        new_params = { user: { nickname: "a" * 31 } }
        patch "/api/v1/users/#{user.id}", params: new_params
        expect(response).to have_http_status(422)
      end
    end
  end
end
