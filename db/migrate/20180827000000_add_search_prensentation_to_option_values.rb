class AddSearchPrensentationToOptionValues < ActiveRecord::Migration[4.2]
  def up
    add_column :spree_option_value_translations, :search_presentation, :string
    add_column :spree_option_values, :search_presentation, :string

  end

  def down
    remove_column :spree_option_value_translations, :search_presentation, :string
    remove_column :spree_option_values, :search_presentation


  end
end
