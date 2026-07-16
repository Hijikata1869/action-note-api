class Api::V1::BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book, only: [ :update, :destroy ]

  def create
    book = current_user.books.build(book_params)
    if book.save
      render json: book, status: :created
    else
      render json: { errors: book.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @book.update(book_params)
      render json: @book, status: :ok
    else
      render json: { errors: @book.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy!
    render json: { message: "書籍を削除しました" }, status: :ok
  end

  private
  def book_params
    params.require(:book).permit(:title, :author, :status)
  end

  def set_book
    @book = current_user.books.find(params[:id])
  end
end
