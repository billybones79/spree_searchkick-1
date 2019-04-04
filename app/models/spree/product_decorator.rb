Spree::Product.class_eval do

  ###############################
  # Override ransack whitelist
  ###############################
  validates :slug, length: { minimum: 3, maximum: 255 }, allow_blank: true, uniqueness: true
  validates :product_code, presence: true
  validates :price,  numericality:{greater_than: 0}
  attr_accessor :highlight_slug

  #pour permettre de preloader c'est mieux un assoc qu'un scope
  has_many :in_stock_variants,
           -> { in_stock.where(is_master: false).order("#{::Spree::Variant.quoted_table_name}.position ASC") },
           inverse_of: :product,
           class_name: 'Spree::Variant'

  has_many :suppliable_variants,
           -> { suppliable.where(is_master: false).order("#{::Spree::Variant.quoted_table_name}.position ASC") },
           inverse_of: :product,
           class_name: 'Spree::Variant'
  has_many :master_variant, ->{ where(is_master: true) }, class_name: 'Spree::Variant'

  translates :name, :description, :meta_description, :meta_keywords, :slug,
             fallbacks_for_empty_translations: true
   translates :content_verified,             fallbacks_for_empty_translations: false
  self.whitelisted_ransackable_attributes =  whitelisted_ransackable_attributes + ['name','custom_fields', 'product_code', 'created_at', 'available_on', 'with_variant_sku', "custom_field", "custom_field2", "custom_field3"]
  self.whitelisted_ransackable_associations = whitelisted_ransackable_associations + ['variant_images', 'master', 'product_properties', 'taxons', 'option_values']



  def self.ransackable_scopes(thefyck)
    [:of_size]
  end

  ###############################
  # Add simple scopes
  ###############################



  scope :ascend_by_updated_at, -> { order(created_at: :asc) }
  scope :descend_by_created_at, -> { order(created_at: :desc) }
  scope :ascend_by_available_on, -> { order(available_on: :asc) }
  scope :descend_by_available_on, -> { order(available_on: :desc) }


  ###############################
  # Translate custom fields
  ###############################


  ###############################
  # New scopes
  ###############################

  def colors
    in_stock_variants.map{|v| v.option_values.colors.select :id }.flatten.uniq.compact
  end
  def sizes
    in_stock_variants.map{|v| v.option_values.sizes.select :id }.flatten.uniq.compact
  end

  def self.search_fields
      ["name_i18n."+I18n.locale.to_s+"^10", "sku^3", "code^10", "brand", "taxon_name_i18n."+I18n.locale.to_s+"^2" ]
  end
  def self.autocomplete_fields
    ["name_i18n."+I18n.locale.to_s+"^10", "sku^3", "code^10", "brand", "taxon_name_i18n."+I18n.locale.to_s+"^2" ]
  end



  def self.autocomplete(keywords)
    if keywords
      Spree::Product.search(
          keywords,
          fields: autocomplete_fields,
          match: :word_start,
          limit: 10,
          load: false,
          operator:"or",
          misspellings: { below: 3 },
      ).map{|r| r[:name_i18n_keyword][I18n.locale]}.map(&:strip).uniq
    else
      Spree::Product.search(
          '*',
          fields: autocomplete_fields,
          load: false,
          misspellings: { below: 3 },
      ).map{|r| p[:name_i18n_keyword][I18n.locale]}.map(&:strip)
    end
  end
  def taxon_and_ancestors
    taxons.map(&:self_and_ancestors).flatten.uniq
  end

  def search_data


    json = {
        price: price,
        currency: Spree::Config.currency,
        sku: sku,
        taxon_ids: taxon_and_ancestors.map(&:id),
        size: sizes.map(&:id),
        color: colors.map(&:id),
        available_on: available_on,

        leftmost_taxon: taxons.minimum(:lft),
        id: id,
        brand:taxons.where(taxonomy: Rails.configuration.brand_id).where.not(parent_id: nil).order(:lft).last.try(:id),
        category:taxons.where(taxonomy: Rails.configuration.category_id).where.not(parent_id: nil).order(:lft).last.try(:id)

    }

   SolidusI18n::Config.available_locales.each do |l|
      json = json.deep_merge({
                                 name_i18n: {l.to_s => name(l.to_sym)},
                                 name_i18n_keyword: {l.to_s => name(l.to_sym)},
                                 description_i18n:{l.to_s => description(l.to_sym)},
                                 taxon_names_i18n:{l.to_s => taxon_and_ancestors.map{|t| t.name(l.to_sym)}},
                             })
    end

    json
  end






  searchkick index_prefix: ENV['ELASTIC_SEARCH_INDEX'] , merge_mappings: true, match: :word_start unless Spree::Product.try(:searchkick_options)



end
