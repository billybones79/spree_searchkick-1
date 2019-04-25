
class AddSortedToOptionTypes < ActiveRecord::Migration[5.0]


  def up
    add_column :spree_option_types, :sorted_by_position, :boolean, default: false
  end

  def down
    remove_column :spree_option_types, :sorted_by_position, :boolean, default: false
  end
end
