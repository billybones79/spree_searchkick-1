Spree::ProductsController.class_eval do

  helper_method :sorting_param
  alias_method :old_index, :index
  respond_to :js, :json
  def index
    @per_page = params[:per_page].blank? ? 48 : params[:per_page]
    @searcher = build_searcher(params.merge(include_images: true, sorting_scope: sorting_scope, per_page: @per_page))
    @products = @searcher.retrieve_products
    @taxonomies = Spree::Taxonomy.includes(root: :children)
    setup_search_filters params.dup, @searcher
  end

  def show
    @variants = @product.variants_including_master.active(current_currency).includes([:option_values, :images])

    @product_properties = @product.product_properties.includes(:property)
    @taxon = Spree::Taxon.includes(:products).limit(4).find(params[:taxon_id]) if params[:taxon_id]
    respond_to do |format|
      format.html {
      }
      format.js {render partial: "spree/shared/single_product", locals:{:product => @product}, :layout => false, cached: true}
    end
  end

  def sorting_param
    params[:sorting].try(:to_sym) || default_sorting
  end

  def image_for
    @product = Spree::Product.find(params[:product_id])
    variant = @product.variants.joins(:option_values).where("spree_option_values.id = ?", params[:value_id]).first
    @image = variant.similar_variant_images.first

  end

  def autocomplete
    render json: Spree::Product.autocomplete(params[:term])
  end



  private

  def sorting_scope
    allowed_sortings.include?(sorting_param) ? sorting_param : default_sorting
  end

  def default_sorting
    :descend_by_available_on
  end

  def allowed_sortings
    [:ascend_by_created_at, :ascend_by_updated_at, :descend_by_created_at, :descend_by_available_on]
  end



end
