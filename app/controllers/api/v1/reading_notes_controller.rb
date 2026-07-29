class Api::V1::ReadingNotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reading_note, only: %i[show update]

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
    render json: @reading_note, status: :ok
  end

  def update
    if @reading_note.update(reading_note_params)
      render json: @reading_note, status: :ok
    else
      render json: { errors: @reading_note.errors.full_messages }, status: :unprocessable_content
    end
  end

  private
  def reading_note_params
    params.require(:reading_note).permit(:content)
  end

  def set_reading_note
    @reading_note = current_user.reading_notes.find(params[:id])
  end
end
