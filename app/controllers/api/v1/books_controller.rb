class Api::V1::BooksController < ApplicationController
  before_action :authenticate_user!

  def create
    book = current_user.books.build(book_params)
    if book.save
      render json: book, status: :created
    else
      render json: { errors: book.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private
  def book_params
    params.require(:book).permit(:title, :author, :status)
  end
end
