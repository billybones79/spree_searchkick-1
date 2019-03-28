Spree::ProductsController.class_eval do

  helper_method :sorting_param
  alias_method :old_index, :index
  respond_to :js, :json
  def index
    get_products
  end

  def sorting_param
    params[:sorting].try(:to_sym) || default_sorting
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
