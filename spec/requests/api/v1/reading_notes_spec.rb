require "rails_helper"

RSpec.describe "Api::V1::ReadingNotes", type: :request do
  let(:user) { create(:user) }
  let(:book) { create(:book, user: user) }
  let(:reading_note) { create(:reading_note, book: book) }
  let(:other_user) { create(:user) }
  let(:other_user_book) { create(:book, user: other_user) }
  let(:other_user_reading_note) { create(:reading_note, book: other_user_book) }

  describe "POST /api/v1/books/:book_id/reading_notes" do
    context "ログイン時" do
      before do
        login_as(user)
      end

      it "正しいパラメーターでPOSTすると201が返ること" do
        params = { reading_note: attributes_for(:reading_note) }
        post "/api/v1/books/#{book.id}/reading_notes", params: params
        expect(response).to have_http_status(201)
      end

      it "正しいパラメータでPOSTするとReadingNote.countが1増えること" do
        params = { reading_note: attributes_for(:reading_note) }
        expect {
          post "/api/v1/books/#{book.id}/reading_notes", params: params
        }.to change(ReadingNote, :count).by(1)
      end

      it "contentが空だと422が返ること" do
        params = { reading_note: attributes_for(:reading_note, content: "") }
        post "/api/v1/books/#{book.id}/reading_notes", params: params
        expect(response).to have_http_status(422)
      end

      it "contentが10000文字だと201が返ること" do
        valid_content = "a" * 10_000
        params = { reading_note: attributes_for(:reading_note, content: valid_content) }
        post "/api/v1/books/#{book.id}/reading_notes", params: params
        expect(response).to have_http_status(201)
      end

      it "contentが10001文字だと422が返ること" do
        invalid_content = "a" * 10_001
        params = { reading_note: attributes_for(:reading_note, content: invalid_content) }
        post "/api/v1/books/#{book.id}/reading_notes", params: params
        expect(response).to have_http_status(422)
      end

      it "すでにメモが存在する本に再度POSTすると422が返ること" do
        reading_note
        new_params = { reading_note: attributes_for(:reading_note, content: "新しい読書メモ") }
        post "/api/v1/books/#{book.id}/reading_notes", params: new_params
        expect(response).to have_http_status(422)
      end

      it "すでにメモが存在する本に再度POSTしてもReadingNote.countの値が1のままであること" do
        reading_note
        new_params = { reading_note: attributes_for(:reading_note, content: "新しい読書メモ") }
        post "/api/v1/books/#{book.id}/reading_notes", params: new_params
        expect(ReadingNote.count).to eq(1)
      end

      it "すでにメモが存在する本に再度POSTしても、内容が書き換えられていないこと" do
        original_content = reading_note.content
        new_params = { reading_note: attributes_for(:reading_note, content: "新しい読書メモ") }
        post "/api/v1/books/#{book.id}/reading_notes", params: new_params
        expect(reading_note.reload.content).to eq(original_content)
      end

      it "他人の本にPOSTしても404が返ってくること" do
        params = { reading_note: attributes_for(:reading_note) }
        post "/api/v1/books/#{other_user_book.id}/reading_notes", params: params
        expect(response).to have_http_status(404)
      end
    end

    context "未ログイン時" do
      it "読書メモを作成しようとすると401が返ること" do
        params = { reading_note: attributes_for(:reading_note) }
        post "/api/v1/books/#{book.id}/reading_notes", params: params
        expect(response).to have_http_status(401)
      end
    end
  end

  describe "GET /api/v1/reading_notes/:id" do
    context "ログイン時" do
      before do
        login_as(user)
      end

      it "読書メモを取得できること" do
        get "/api/v1/reading_notes/#{reading_note.id}"
        expect(response).to have_http_status(200)
        result = JSON.parse(response.body)
        expect(result["id"]).to eq(reading_note.id)
        expect(result["content"]).to eq(reading_note.content)
      end

      it "他人のメモを取得しようとすると404が返ること" do
        get "/api/v1/reading_notes/#{other_user_reading_note.id}"
        expect(response).to have_http_status(404)
      end

      it "存在しない読書メモidを取得しようとすると404が返ること" do
        get "/api/v1/reading_notes/999999"
        expect(response).to have_http_status(404)
      end
    end

    context "未ログイン時" do
      it "読書メモを取得しようとすると401が返ること" do
        get "/api/v1/reading_notes/#{reading_note.id}"
        expect(response).to have_http_status(401)
      end
    end
  end

  describe "PATCH /api/v1/reading_notes/:id" do
    context "ログイン時" do
      before do
        login_as(user)
      end

      it "読書メモの内容が更新されること" do
        new_params = { reading_note: { content: "新しいコンテンツ" } }
        patch "/api/v1/reading_notes/#{reading_note.id}", params: new_params
        expect(response).to have_http_status(200)
        result = JSON.parse(response.body)
        expect(reading_note.book_id).to eq(result["book_id"])
        expect(reading_note.reload.content).to eq(result["content"])
      end

      it "contentが空だと422が返ること" do
        original_content = reading_note.content
        new_params = { reading_note: { content: "" } }
        patch "/api/v1/reading_notes/#{reading_note.id}", params: new_params
        expect(response).to have_http_status(422)
        expect(reading_note.reload.content).to eq(original_content)
      end

      it "contentが10000文字だと200が返ること" do
        new_params = { reading_note: { content: "a" * 10_000 } }
        patch "/api/v1/reading_notes/#{reading_note.id}", params: new_params
        expect(response).to have_http_status(200)
        result = JSON.parse(response.body)
        expect(reading_note.book_id).to eq(result["book_id"])
        expect(reading_note.reload.content).to eq(result["content"])
      end

      it "contentが10001文字だと422が返ること" do
        original_content = reading_note.content
        new_params = { reading_note: { content: "a" * 10_001 } }
        patch "/api/v1/reading_notes/#{reading_note.id}", params: new_params
        expect(response).to have_http_status(422)
        expect(reading_note.reload.content).to eq(original_content)
      end

      it "他人のメモを更新しようとすると404が返ること" do
        original_content = other_user_reading_note.content
        new_params = { reading_note: { content: "乗っ取り試行" } }
        patch "/api/v1/reading_notes/#{other_user_reading_note.id}", params: new_params
        expect(response).to have_http_status(404)
        expect(other_user_reading_note.reload.content).to eq(original_content)
      end
    end

    context "未ログイン時" do
      it "読書メモを更新しようとすると401が返ること" do
        original_content = reading_note.content
        new_params = { reading_note: { content: "新しいコンテンツ" } }
        patch "/api/v1/reading_notes/#{reading_note.id}", params: new_params
        expect(response).to have_http_status(401)
        expect(reading_note.reload.content).to eq(original_content)
      end
    end
  end
end
