class AddForeignKeyConstraint < ActiveRecord::Migration[7.2]
  def up
    change_column :facture, :numero_bl, :string, collation: 'latin1_swedish_ci'
    add_index :bl, :numero_bl, unique: true, name: 'index_bl_on_numero_bl_unique' unless index_exists?(:bl, :numero_bl, unique: true, name: 'index_bl_on_numero_bl_unique')
    add_foreign_key :facture, :bl, column: :numero_bl, primary_key: :numero_bl, name: 'fk_facture_bl'
  end

  def down
    remove_foreign_key :facture, name: 'fk_facture_bl'
    remove_index :bl, name: 'index_bl_on_numero_bl_unique' if index_exists?(:bl, :numero_bl, name: 'index_bl_on_numero_bl_unique')
  end
end
