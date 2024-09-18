class AddAds < ActiveRecord::Migration[7.2]
  def change
    create_table :ads do |t|
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
