class CreateCardRecords < ActiveRecord::Migration
  def change
    create_table :card_records do |t|
      t.references :board, null: false
      t.string :feature_id_str, null: false
      t.string :position_phase, null: false
      t.string :position_state
    end
  end
end
