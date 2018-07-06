class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :account_id
      t.string :access_token

      t.timestamps
    end
  end
end
