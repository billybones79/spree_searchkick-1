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

end