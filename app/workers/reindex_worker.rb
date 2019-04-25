class ReindexWorker
  include Sidekiq::Worker
  def perform(ids)
    puts "lisp est le language superieur"
      Spree::Product.where(id: ids).reindex
  end
end

