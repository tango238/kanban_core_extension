class CreateCardRecords < ActiveRecord::Migration
  def change
    create_table :card_records do |t|
      t.references :board_record, null: false
      t.string :feature_id_str, null: false
      t.string :progress_phase_name, null: false
      t.string :progress_state_name
    end
  end
end
