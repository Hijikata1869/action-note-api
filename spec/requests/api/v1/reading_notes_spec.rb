require "rails_helper"

RSpec.describe "Api::V1::ReadingNotes", type: :request do
  describe "POST /api/v1/books/:book_id/reading_notes" do
    let(:user) { create(:user) }
    let(:book) { create(:book, user: user) }
    let(:existing_note) { create(:reading_note, book: book) }
    let(:other_user) { create(:user) }
    let(:other_user_book) { create(:book, user: other_user) }

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
        existing_note
        new_params = { reading_note: attributes_for(:reading_note, content: "新しい読書メモ") }
        post "/api/v1/books/#{book.id}/reading_notes", params: new_params
        expect(response).to have_http_status(422)
      end

      it "すでにメモが存在する本に再度POSTしてもReadingNote.countの値が1のままであること" do
        existing_note
        new_params = { reading_note: attributes_for(:reading_note, content: "新しい読書メモ") }
        post "/api/v1/books/#{book.id}/reading_notes", params: new_params
        expect(ReadingNote.count).to eq(1)
      end

      it "すでにメモが存在する本に再度POSTしても、内容が書き換えられていないこと" do
        original_content = existing_note.content
        new_params = { reading_note: attributes_for(:reading_note, content: "新しい読書メモ") }
        post "/api/v1/books/#{book.id}/reading_notes", params: new_params
        expect(existing_note.reload.content).to eq(original_content)
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
end
