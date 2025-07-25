class AddPerformanceRelatedIndexes < ActiveRecord::Migration[7.2]
  def up
    add_index :bl, [:arrival_date, :freetime], name: 'idx_bl_arrival_freetime' unless index_exists?(:bl, [:arrival_date, :freetime], name: 'idx_bl_arrival_freetime')
    add_index :bl, :exempted, name: 'idx_bl_exempt' unless index_exists?(:bl, :exempted, name: 'idx_bl_exempt')
    add_index :facture, [:bl_number, :status], name: 'idx_facture_bl_status' unless index_exists?(:facture, [:bl_number, :status], name: 'idx_facture_bl_status')
    add_index :remboursement, [:bl_number, :status], name: 'idx_remboursement_bl_status' unless index_exists?(:remboursement, [:bl_number, :status], name: 'idx_remboursement_bl_status')
  end

  def down
    remove_index :bl, column: [:arrival_date, :freetime] if index_exists?(:bl, [:arrival_date, :freetime])
    remove_index :bl, column: :exempted if index_exists?(:bl, :exempted)
    # Skip removing idx_facture_bl_status to avoid breaking FK
    remove_index :remboursement, column: [:bl_number, :status] if index_exists?(:remboursement, [:bl_number, :status])
  end
end
