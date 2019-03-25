class AddActiveFromToToTaxon < ActiveRecord::Migration
  def change
    add_column(:spree_taxons, :active_from, :datetime)
    add_column(:spree_taxons, :active_to, :datetime)

  end

end
