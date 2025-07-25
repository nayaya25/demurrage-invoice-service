class RenameFrenchColumns < ActiveRecord::Migration[7.2]
  def up
    # Renaming key French columns to English on the bl table
    rename_column :bl, :numero_bl, :number
    rename_column :bl, :nbre_20pieds_sec, :containers_20ft_dry
    rename_column :bl, :nbre_40pieds_sec, :containers_40ft_dry
    rename_column :bl, :nbre_20pieds_frigo, :containers_20ft_reefer
    rename_column :bl, :nbre_40pieds_frigo, :containers_40ft_reefer
    rename_column :bl, :nbre_20pieds_special, :containers_20ft_special
    rename_column :bl, :nbre_40pieds_special, :containers_40ft_special
    rename_column :bl, :exempte, :exempted

    # Same for client table
    rename_column :client, :nom, :name
    rename_column :client, :code_client, :code
    rename_column :client, :prioritaire, :priority

    # Same for client facture table
    rename_column :facture, :numero_bl, :bl_number
    rename_column :facture, :code_client, :customer_code
    rename_column :facture, :nom_client, :customer_name
    rename_column :facture, :montant_facture, :amount
    rename_column :facture, :devise, :currency
    rename_column :facture, :statut, :status

    # Same for client remboursement table
    rename_column :remboursement, :numero_bl, :bl_number
    rename_column :remboursement, :montant_demande, :amount_requested
    rename_column :remboursement, :statut, :status
  end

  def down
    rename_column :bl, :number, :numero_bl
    rename_column :bl, :containers_20ft_dry, :nbre_20pieds_sec
    rename_column :bl, :containers_40ft_dry, :nbre_40pieds_sec
    rename_column :bl, :containers_20ft_reefer, :nbre_20pieds_frigo
    rename_column :bl, :containers_40ft_reefer, :nbre_40pieds_frigo
    rename_column :bl, :containers_20ft_special, :nbre_20pieds_special
    rename_column :bl, :containers_40ft_special, :nbre_40pieds_special
    rename_column :bl, :exempted, :exempte

    rename_column :client, :priority, :prioritaire
    rename_column :client, :name, :nom
    rename_column :client, :code, :code_client

    rename_column :facture, :bl_number, :numero_bl
    rename_column :facture, :customer_code, :code_client
    rename_column :facture, :customer_name, :nom_client
    rename_column :facture, :amount, :montant_facture
    rename_column :facture, :currency, :devise
    rename_column :facture, :status, :statut

    rename_column :remboursement, :bl_number, :numero_bl
    rename_column :remboursement, :amount_requested, :montant_demande
    rename_column :remboursement, :status, :statut
  end
end

