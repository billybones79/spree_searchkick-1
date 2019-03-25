Spree::ProductsHelper.class_eval do
  def product_description(product)
    if Spree::Config[:show_raw_product_description]
      raw(product.translation_for(I18n.locale).description)
    else
      raw(product.translation_for(I18n.locale).description.gsub(/(.*?)\r?\n\r?\n/m, '<p>\1</p>'))
    end
  end

  def cache_key_for_products
    count = @products.count
    max_updated_at = (@products.map(&:updated_at).max || Date.today).to_s(:number)
    "#{I18n.locale}/#{current_currency}/spree/products/all-#{params[:page]}-#{max_updated_at}-#{count}"
  end

end