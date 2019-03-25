Spree::Variant.class_eval do

  include ActionView::Helpers::NumberHelper

  has_many :active_sale_prices, through: :prices

  self.whitelisted_ransackable_associations = whitelisted_ransackable_associations + ['images']

  def to_hash
    #actual_price += Calculator::Vat.calculate_tax_on(self) if Spree::Config[:show_price_inc_vat]
    {
        :id    => self.id,
        :in_stock => self.in_stock?,
        :price => price_in(Spree::Config[:currency]).display_price
    }
  end




  #//va essayer de trouver une image qui est reliÃ© a une variante qui partage un option dont le type a 'has_image'
  def similar_variant_images

    return images unless images.size == 0

    #possible_option_values = self.option_values.select(:name){|option_value| option_value.option_type.has_image?}
    # on se pogne les variants du produit en haut, qui partagent une option value avec has_image
    possible_variants = self.product.variants.joins(:option_values =>[:option_type]).where({"spree_option_values.id" => self.option_values}).where("spree_option_types.has_image = true")

    possible_variants.each do |variant|
      unless variant.images.length.size == 0
        return variant.images
      end

    end

    images
  end

  def first_image
    if similar_variant_images.any?
      return similar_variant_images.first
    else
      return product.images.first
    end
  end


end