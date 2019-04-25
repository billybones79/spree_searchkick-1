Spree::Taxon.class_eval do
  after_save :reindex_products

  def reindex_products
    self_and_descendants.each_with_index do |t, i|
      ReindexWorker.perform_at(Time.now + (i*15).seconds, t.products.pluck(:id))
    end
  end

end