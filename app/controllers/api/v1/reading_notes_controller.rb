class Api::V1::ReadingNotesController < ApplicationController
  before_action :authenticate_user!

  def create
    book = current_user.books.find(params[:book_id])
    reading_note = ReadingNote.new(reading_note_params.merge(book_id: book.id))
    if reading_note.save
      render json: reading_note, status: :created
    else
      render json: { errors: reading_note.errors.full_messages }, status: :unprocessable_content
    end
  end

  def show
    reading_note = current_user.reading_notes.find(params[:id])
    render json: reading_note, status: :ok
  end

  private
  def reading_note_params
    params.require(:reading_note).permit(:content)
  end
end
