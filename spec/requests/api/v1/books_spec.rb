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
end
