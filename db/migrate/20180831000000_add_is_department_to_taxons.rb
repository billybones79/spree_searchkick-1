class AddIsDepartmentToTaxons < ActiveRecord::Migration
  def change
    add_column :spree_taxons, :is_department, :boolean, default: false

  end

end
