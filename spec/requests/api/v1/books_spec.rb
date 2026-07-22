require "rails_helper"

RSpec.describe "Api::V1::Books", type: :request do
  describe "POST /api/v1/books" do
    let(:user) { create(:user) }
    context "ログイン時" do
      before do
        login_as(user)
      end
      it "正しいパラメーターでPOSTすると201が返ること" do
        params = { book: attributes_for(:book) }
        post "/api/v1/books", params: params
        expect(response).to have_http_status(201)
      end

      it "正しいパラメーターでPOSTするとBook.countが1増えること" do
        params = { book: attributes_for(:book) }
        expect {
          post "/api/v1/books", params: params
        }.to change(Book, :count).by(1)
      end

      it "作成された書籍がログインユーザーに紐づくこと" do
        params = { book: attributes_for(:book) }
        post "/api/v1/books", params: params
        expect(Book.last.user).to eq(user)
      end

      it "statusはデフォルトでfinishedで作成されること" do
        params = { book: attributes_for(:book).except(:status) }
        post "/api/v1/books", params: params
        expect(Book.last.status).to eq("finished")
      end

      it "titleが空の場合422が返ること" do
        params = { book: attributes_for(:book, title: "") }
        post "/api/v1/books", params: params
        expect(response).to have_http_status(422)
      end

      it "titleが空の場合Bookが作成されていないこと" do
        params = { book: attributes_for(:book, title: "") }
        expect {
          post "/api/v1/books", params: params
        }.not_to change(Book, :count)
      end

      it "authorが空の場合422が返ること" do
        params = { book: attributes_for(:book, author: "") }
        post "/api/v1/books", params: params
        expect(response).to have_http_status(422)
      end

      it "statusが空の場合422が返ること" do
        params = { book: attributes_for(:book, status: "") }
        post "/api/v1/books", params: params
        expect(response).to have_http_status(422)
      end

      it "statusにfinished, reading, tsundoku以外の文字列が入ると422が返ること" do
        params = { book: attributes_for(:book, status: "unread") }
        post "/api/v1/books", params: params
        expect(response).to have_http_status(422)
      end
    end

    context "未ログインの場合" do
      it "正しいパラメーターでPOSTしても401が返ること" do
        params = { book: attributes_for(:book) }
        post "/api/v1/books", params: params
        expect(response).to have_http_status(401)
      end
    end
  end
  describe "DELETE /api/v1/books/:id" do
    let(:user) { create(:user) }
    let(:book) { create(:book, user: user) }
    let(:other_user) { create(:user) }
    let(:other_book) { create(:book, user: other_user) }

    context "ログイン時" do
    before do
      login_as(user)
    end
      it "書籍が削除されること" do
        delete "/api/v1/books/#{book.id}"
        expect(response).to have_http_status(200)
        expect(Book.exists?(book.id)).to be false
      end

      it "Book.countが1減ること" do
        book_id = book.id # changeの観測前にbookを実体化させている
        expect {
          delete "/api/v1/books/#{book_id}"
        }.to change(Book, :count).by(-1)
      end

      it "存在しないidを指定すると404が返ること" do
        delete "/api/v1/books/99999"
        expect(response).to have_http_status(404)
      end

      it "他人の本を削除しようとすると404が返ること" do
        delete "/api/v1/books/#{other_book.id}"
        expect(response).to have_http_status(404)
      end

      it "他人の本は削除されていないこと" do
        delete "/api/v1/books/#{other_book.id}"
        expect(Book.exists?(other_book.id)).to be true
      end
    end

    context "未ログインの場合" do
      it "401が返ること" do
        delete "/api/v1/books/#{book.id}"
        expect(response).to have_http_status(401)
      end

      it "書籍は削除されていないこと" do
        delete "/api/v1/books/#{book.id}"
        expect(Book.exists?(book.id)).to be true
      end
    end
  end

  describe "PATCH /api/v1/books/:id" do
    let(:user) { create(:user) }
    let(:book) { create(:book, user: user) }
    let(:other_user) { create(:user) }
    let(:other_book) { create(:book, user: other_user) }

    context "ログイン時" do
      before do
        login_as(user)
      end

      it "titleが更新されること" do
        new_params = { book: { title: "新しいタイトル" } }
        patch "/api/v1/books/#{book.id}", params: new_params
        expect(response).to have_http_status(200)
        expect(book.reload.title).to eq("新しいタイトル")
      end

      it "authorが更新されること" do
        new_params = { book: { author: "新しい著者" } }
        patch "/api/v1/books/#{book.id}", params: new_params
        expect(book.reload.author).to eq("新しい著者")
      end

      it "statusが更新されること" do
        new_params = { book: { status: "tsundoku" } }
        patch "/api/v1/books/#{book.id}", params: new_params
        expect(book.reload.status).to eq("tsundoku")
      end

      it "空文字でtitleにPATCHリクエストを送ると422が返ること" do
        new_params = { book: { title: "" } }
        patch "/api/v1/books/#{book.id}", params: new_params
        expect(response).to have_http_status(422)
      end

      it "enumに存在しないstatusを指定すると422が返ること" do
        new_params = { book: { status: "unread" } }
        patch "/api/v1/books/#{book.id}", params: new_params
        expect(response).to have_http_status(422)
      end

      it "空文字でauthorにPATCHリクエストを送ると422が返ること" do
        new_params = { book: { author: "" } }
        patch "/api/v1/books/#{book.id}", params: new_params
        expect(response).to have_http_status(422)
      end

      it "他人の書籍の情報を更新しようとすると404が返ること" do
        new_params = { book: { title: "新しいタイトル" } }
        patch "/api/v1/books/#{other_book.id}", params: new_params
        expect(response).to have_http_status(404)
      end

      it "他人の書籍情報は更新されていないこと" do
        original_title = other_book.title
        new_params = { book: { title: "新しいタイトル" } }
        patch "/api/v1/books/#{other_book.id}", params: new_params
        expect(other_book.reload.title).to eq(original_title)
      end
    end

    context "未ログイン時" do
      it "PATCHリクエストを送ると401が返ること" do
        new_params = { book: { title: "新しいタイトル" } }
        patch "/api/v1/books/#{book.id}", params: new_params
        expect(response).to have_http_status(401)
      end

      it "書籍の情報が更新されていないこと" do
        original_title = book.title
        new_params = { book: { title: "新しいタイトル" } }
        patch "/api/v1/books/#{book.id}", params: new_params
        expect(book.reload.title).to eq(original_title)
      end
    end
  end

  describe "GET /api/v1/books/:id" do
    let(:user) { create(:user) }
    let(:book) { create(:book, user: user) }
    let(:other_user) { create(:user) }
    let(:other_book) { create(:book, user: other_user) }

    context "ログイン時" do
      before do
        login_as(user)
      end
      it "書籍詳細情報が取得できること" do
        get "/api/v1/books/#{book.id}"
        result = JSON.parse(response.body)
        expect(response).to have_http_status(200)
        expect(result["title"]).to eq(book.title)
      end

      it "存在しないidを指定すると404が返ること" do
        get "/api/v1/books/99999"
        expect(response).to have_http_status(404)
      end

      it "他人の書籍情報を取得しようとすると404が返ること" do
        get "/api/v1/books/#{other_book.id}"
        expect(response).to have_http_status(404)
      end
    end

    context "非ログイン時" do
      it "書籍情報を取得しようとすると401が返ること" do
        get "/api/v1/books/#{book.id}"
        expect(response).to have_http_status(401)
      end
    end
  end

  describe "GET /api/v1/books" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let!(:other_book) { create(:book, user: other_user) }

    context "ログイン時" do
      before do
        login_as(user)
      end

      it "自分の書籍一覧を取得できること" do
        create_list(:book, 2, user: user)
        get "/api/v1/books"
        result = JSON.parse(response.body)
        expect(result.length).to eq(2)
        expect(result.map { |b| b["id"] }).to_not include(other_book.id)
      end

      it "自分の書籍が存在しない場合空配列が返ること" do
        get "/api/v1/books"
        result = JSON.parse(response.body)
        expect(result).to eq([])
      end
    end

    context "非ログイン時" do
      it "書籍一覧を取得しようとすると401が返ること" do
        create_list(:book, 2, user: user)
        get "/api/v1/books"
        expect(response).to have_http_status(401)
      end
    end
  end
end
