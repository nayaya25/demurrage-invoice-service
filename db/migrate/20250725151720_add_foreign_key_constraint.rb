class AddForeignKeyConstraint < ActiveRecord::Migration[7.2]
  def change
    # Added these because the collation mismatch in the tables prevents adding of the FK constraint
    change_column :facture, :numero_bl, :string,  collation: 'latin1_swedish_ci'
    # Similar with this, the numero_bl must be unique to be able to be made a FK
    add_index :bl, :numero_bl, unique: true, name: 'index_bl_on_numero_bl_unique'
    # Add missing FK constraint from facture.numero_bl to bl.numero_bl as instructed
    add_foreign_key :facture, :bl, column: :numero_bl, primary_key: :numero_bl, name: 'fk_facture_bl'
  end
end
