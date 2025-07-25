class RenameFrenchColumns < ActiveRecord::Migration[7.2]
  def change
    # Renaming key French columns to English on the bl table
    rename_column :bl, :numero_bl, :number # BL number - I need it to be in english
    rename_column :bl, :nbre_20pieds_sec, :containers_20ft_dry
    rename_column :bl, :nbre_40pieds_sec, :containers_40ft_dry
    rename_column :bl, :nbre_20pieds_frigo, :containers_20ft_reefer
    rename_column :bl, :nbre_40pieds_frigo, :containers_40ft_reefer
    rename_column :bl, :nbre_20pieds_special, :containers_20ft_special
    rename_column :bl, :nbre_40pieds_special, :containers_40ft_special

    # Same for client table
    rename_column :client, :nom, :name              # Customer name
    rename_column :client, :code_client, :code      # Customer code

    # Same for client facture table
    rename_column :facture, :numero_bl, :bl_number  # Matching renamed bl.number
    rename_column :facture, :code_client, :customer_code
    rename_column :facture, :nom_client, :customer_name
    rename_column :facture, :montant_facture, :amount
    rename_column :facture, :devise, :currency
    rename_column :facture, :statut, :status

    # Same for client remboursement table
    rename_column :remboursement, :numero_bl, :bl_number  # Matching renamed bl.number
    rename_column :remboursement, :montant_demande, :amount_requested
    rename_column :remboursement, :statut, :status
  end
end
