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
  
  def setup_search_filters params, searcher

    params[:filter] ||= {"brand"=>[""], "category"=>[""], "color"=>[""], "size"=>[""]}
    params[:taxon] ||= Spree::Taxonomy.first
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
      params_color = params.dup
      params_color[:filter].delete("color") if  params_color[:filter]
      params_color.delete("page")
      params_color[:per_page]=100000
      params_color[:body_options] = {size: '0', aggs: {uniq_colors: {terms: {field: :color, size: '1000'}}}}

      searcher.reinitialize(params_color)
      colors = searcher.retrieve_products
      Spree::OptionValue.includes(:translations).where( id: (colors.aggs["uniq_colors"]["buckets"].map{|b| b["key"]}))
    end

    @sizes =  Rails.cache.fetch(["sizes_filter", params]) do
      params_size = params.dup
      params_size[:filter].delete("size") if  params_size[:filter]
      params_size.delete("page")
      params_size[:per_page]=100000
      params_size[:body_options] = {size: '0', aggs: {uniq_sizes: {terms: {field: :size, size: '1000'}}}}
      searcher.reinitialize(params_size)
      Spree::OptionValue.includes(:translations).where( id: searcher.retrieve_products.aggs["uniq_sizes"]["buckets"].map{|b| b["key"]})
    end


    @brand = Rails.cache.fetch(["brands_filter", params]) do
      params_brand = params.dup
      params_brand[:filter].delete("brand") if  params_brand[:filter]
      params_brand.delete("page")
      params_brand[:per_page]=100000
      params_brand[:taxon]= Rails.configuration.brand_id
      params_brand[:body_options] = {size: '0', aggs: {uniq_brands: {terms: {field: :brand, size: '1000'}}}}

      searcher.reinitialize(params_brand)

      Spree::Taxon.where(id: searcher.retrieve_products.aggs["uniq_brands"]["buckets"].map{|b| b["key"]}).includes(:translations)
    end
    @category = Rails.cache.fetch(["categories_filter", params]) do
      params_category = params.dup
      params_category[:filter].delete("category") if  params_category[:filter]
      params_category.delete("page")
      params_category[:per_page]=100000
      params_category[:taxon]= Rails.configuration.category_id


      params_category[:body_options] = {size: '0', aggs: {uniq_categories: {terms: {field: :category, size: '1000'}}}}

      searcher.reinitialize(params_category)
      Spree::Taxon.where(id: searcher.retrieve_products.aggs["uniq_categories"]["buckets"].map{|b| b["key"]}).includes(:translations)
    end


    @filters = []

    @filters << Rails.cache.fetch(["searchkick_filter_brands", @brand]) do
      Spree::Core::SearchkickFilters.brand_filter(@brand)
    end
    @filters << Rails.cache.fetch(["searchkick_filter_categories", @category]) do
      Spree::Core::SearchkickFilters.category_filter(@category)
    end

    @filters << Rails.cache.fetch(["searchkick_filter_colors", @colors]) do
      Spree::Core::SearchkickFilters.color_select_filter(@colors)
    end
    @filters << Rails.cache.fetch(["searchkick_filter_sizes", @sizes]) do
      Spree::Core::SearchkickFilters.size_select_filter(@sizes)
    end



  end

  private

  def search_params
    params.permit!
  end


end