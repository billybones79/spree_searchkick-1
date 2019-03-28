class AddActiveFromToToTaxon < ActiveRecord::Migration[4.2]
  def change
    add_column(:spree_taxons, :active_from, :datetime)
    add_column(:spree_taxons, :active_to, :datetime)

  end

end
