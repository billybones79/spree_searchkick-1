
Spree::OptionValue.class_eval do

  default_scope { order("#{quoted_table_name}.position") }
  scope :for_product, lambda { |product| select("DISTINCT #{table_name}.*").where("spree_option_values_variants.variant_id IN (?)", product.variant_ids).joins(:variants) }
  scope :colors, ->{ where(option_type_id: Spree::OptionType.color.reorder(""))}
  scope :sizes, ->{ where(option_type_id: Spree::OptionType.clothe_size.reorder(""))}

  translates :search_presentation

  def maybe_search_presentation(locale = I18n.locale)

    return search_presentation(locale).blank? ? presentation(locale) : search_presentation(locale)
  end
end