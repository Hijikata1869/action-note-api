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

      it "作成と同時にログイン状態になること" do
        params = { user: attributes_for(:user) }
        post "/api/v1/users", params: params
        expect(session[:user_id]).to eq(User.last.id)
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
    let(:user) { create(:user, password: "password123") }

    context "ログイン中の本人が更新する場合" do
      before do
        post "/api/v1/session", params: { email: user.email, password: "password123" }
      end

      it "nicknameが更新されること" do
        new_params = { user: { nickname: "新しいニックネーム" } }
        patch "/api/v1/users/#{user.id}", params: new_params
        expect(response).to have_http_status(200)
        expect(user.reload.nickname).to eq("新しいニックネーム")
      end

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

    context "未ログインの場合" do
      it "PATCHリクエストを送ると401が返ること" do
        new_params = { user: { nickname: "新しいニックネーム" } }
        patch "/api/v1/users/#{user.id}", params: new_params
        expect(response).to have_http_status(401)
      end
    end

    context "他人としてログイン中の場合" do
      let(:other_user) { create(:user, password: "password123") }

      before do
        post "/api/v1/session", params: { email: other_user.email, password: "password123" }
      end

      it "指定したユーザー(user)は更新されず、ログイン中の本人が更新されること" do
        new_params = { user: { nickname: "乗っ取り試行" } }
        patch "/api/v1/users/#{user.id}", params: new_params
        expect(user.reload.nickname).not_to eq("乗っ取り試行")
        expect(other_user.reload.nickname).to eq("乗っ取り試行")
      end
    end
  end

  describe "DELETE /api/v1/users/:id" do
    let(:user) { create(:user, password: "password123") }

    context "ログイン中の本人が削除する場合" do
      before do
        post "/api/v1/session", params: { email: user.email, password: "password123" }
      end

      it "ログイン中の本人が削除されること" do
        delete "/api/v1/users/#{user.id}"
        expect(response).to have_http_status(200)
        expect(User.exists?(user.id)).to be false
      end

      it "セッションのuser_idが削除されること" do
        delete "/api/v1/users/#{user.id}"
        expect(session[:user_id]).to be_nil
      end
    end

    context "未ログインの場合" do
      it "401が返ること" do
        delete "/api/v1/users/#{user.id}"
        expect(response).to have_http_status(401)
      end
    end

    context "他人としてログイン中の場合" do
      let(:other_user) { create(:user, password: "password123") }

      before do
        post "/api/v1/session", params: { email: other_user.email, password: "password123" }
      end

      it "指定したユーザー(user)は削除されず、ログイン中の本人(other_user)が削除されること" do
        delete "/api/v1/users/#{user.id}"
        expect(User.exists?(user.id)).to be true
        expect(User.exists?(other_user.id)).to be false
      end
    end
  end
end
