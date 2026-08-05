FactoryBot.define do
  factory :reading_note do
    content { "読書メモの内容" }
    book
  end
end
