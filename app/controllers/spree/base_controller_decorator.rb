Spree::BaseController.class_eval do
  def set_user_language
    I18n.locale = if params[:locale] && SpreeI18n::Config.supported_locales.include?(params[:locale].to_sym)
                    params[:locale]
                  elsif respond_to?(:config_locale, true) && !config_locale.blank?
                    config_locale
                  else
                    Rails.application.config.i18n.default_locale || I18n.default_locale
                  end
  end

  def get_products
    @per_page = search_params[:per_page].blank? ? 10 : search_params[:per_page]
    @searcher = build_searcher(search_params.merge(include_images: true, sorting_scope: sorting_scope, per_page: @per_page))
    @products = @searcher.retrieve_products
    setup_search_filters search_params.dup, @searcher
  end

  def prepare_param(name, params, searcher, info)
    params_p = params.dup
    params_p[:filter].delete(name.to_s) if  params_p[:filter]
    params_p.delete("page")
    params_p[:per_page]=100000
    params_p[:body_options] = {size: '0', aggs: {}}
    params_p[:body_options][:aggs] = Hash["uniq_".concat(name.to_s+"s").to_sym, {terms: {field: name , size: '1000'}}]

    searcher.reinitialize(params_p)
    field_name = searcher.retrieve_products
    if info == :taxon
      Spree::Taxon.includes(:translations).where( id: (field_name.aggs["uniq_".concat(name.to_s+"s")]["buckets"].map{|b| b["key"]}))
    elsif info == :option
      Spree::OptionValue.includes(:translations).where( id: (field_name.aggs["uniq_".concat(name.to_s+"s")]["buckets"].map{|b| b["key"]}))
    end

  end

  def setup_search_filters params, searcher
    params[:filter] ||= {"brand"=>[""], "category"=>[""], "color"=>[""], "size"=>[""]}
    params = params.to_h
    params_taxon = params.dup
    params_taxon[:filter].delete("taxon_ids") if  params_taxon[:filter]
    params_taxon.delete("taxons")
    params_taxon.delete("page")
    params_taxon[:per_page]=100000


    params_taxon[:body_options] = {size: '0', aggs: {uniq_taxons: {terms: {field: :taxon_ids, size: '1000'}}}}
    @possible_taxons_ids = Rails.cache.fetch(["taxons_filter", params_taxon]) do


      searcher.reinitialize(params_taxon)

      searcher.retrieve_products.aggs["uniq_taxons"]["buckets"].map{|b| b["key"]}
    end
    @colors = Rails.cache.fetch(["colors_filter", params]) do
      prepare_param(:color, params, searcher, :option)
    end

    @sizes =  Rails.cache.fetch(["sizes_filter", params]) do
      prepare_param(:size, params, searcher, :option)
    end

    @brand = Rails.cache.fetch(["brands_filter", params]) do
      prepare_param(:brand, params, searcher, :taxon)
    end
    @category = Rails.cache.fetch(["categories_filter", params]) do
      prepare_param(:category, params, searcher, :taxon)
    end

    @filters = []
    @filters << Rails.cache.fetch(["searchkick_filter_brands", @brand]) do
      Spree::Core::TxFilter.new(:brand, @brand)
    end
    @filters << Rails.cache.fetch(["searchkick_filter_categories", @category]) do
      Spree::Core::TxFilter.new(:category, @category)
    end

    @filters << Rails.cache.fetch(["searchkick_filter_colors", @colors]) do
      Spree::Core::OvFilter.new(:color, @colors)
    end
    @filters << Rails.cache.fetch(["searchkick_filter_sizes", @sizes]) do
      Spree::Core::OvFilter.new(:size, @sizes)
    end


  end

  private

  def search_params
    params.permit!
  end


end