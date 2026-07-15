class AddStatusToBooks < ActiveRecord::Migration[8.1]
  def change
    add_column :books, :status, :integer, default: 0, null: false
  end
end
