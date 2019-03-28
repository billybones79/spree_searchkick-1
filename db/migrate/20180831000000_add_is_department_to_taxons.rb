class AddIsDepartmentToTaxons < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_taxons, :is_department, :boolean, default: false

  end

end
