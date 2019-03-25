Spree::BaseHelper.class_eval do

  def cached_recently_viewed_products
    Spree::Product.preload(master: :images).active.where("spree_products.id in (?)", cached_recently_viewed_products_ids)
  end

  def meta_data

    object =  instance_variable_get('@'+controller_name.singularize)
    meta = @meta ? @meta : {}

    if object.kind_of? ActiveRecord::Base
      meta[:keywords] = object.meta_keywords if object[:meta_keywords].present?
      meta[:description] = object.meta_description if object[:meta_description].present?

    end

    meta.reverse_merge!({
                            keywords: current_store.meta_keywords,
                            description: current_store.meta_description,
                        }) if meta[:keywords].blank? or meta[:description].blank?
    meta
  end

  def order_options add_vehicle_filters = false
    order_options = []
    order_options += [[t("score"), '_score:desc'],
                      [t("product.name"), 'name:asc'],
                      [t("price_low_to_high"), 'price:asc'],
                      [t("price_high_to_low"), 'price:desc'],
                      [t("new_to_old"), 'available_on:desc'],
                       [t("old_to_new"), 'available_on:asc']]

    order_options
  end

  def cache_key_for_promos
    count          = Spree::Promotion.active.advertised
    max_updated_at = Spree::Promotion.active.advertised.maximum(:updated_at).try(:utc).try(:to_s, :number)
    "promotions/all-#{count}-#{max_updated_at}"
  end

  def display_section_header(taxon)

    t = taxon.self_and_ancestors.where("section_header_#{I18n.locale.to_s}_file_name IS NOT NULL").order("rgt ASC").last || taxon
    options = {}

    options['data-original'] = t.try(:"section_header_#{I18n.locale.to_s}").url(:large)
    options[:class] = 'deferred_img section_header_banner'

    if t.banner_link.blank?
      image_tag "noimage/large.png", options
    else
      link_to image_tag("noimage/large.png", options), t.banner_link
    end


  end

  def shipping_discount
    Spree::Promotion.active.any? do |p|
          p.promotion_actions.any? do |action|
            action.is_a?(Spree::Promotion::Actions::DiscountShipping)
          end
    end
  end


  def get_sizing_chart(product)

    brand = product.taxons.where(taxonomy_id: 1).pluck(:id)
    taxons = product.taxons.where(taxonomy_id: 2).map(&:self_and_ancestors).flatten.uniq

    chart = Spree::SizingChart.where("taxon_id IN (?) AND brand_id IN (?)", taxons, brand).joins(:taxon).order("spree_taxons.rgt")

    return nil if chart.empty?

    chart

  end

  def breadcrumbs(taxon, separator="&nbsp;", postfix="")
    return "" if current_page?("/") || taxon.nil?
    separator = raw("&nbsp;>&nbsp;")
    crumbs = [content_tag(:li, content_tag(:span, link_to(content_tag(:span, Spree.t(:home), itemprop: "name"), spree.root_path, itemprop: "url") + separator, itemprop: "item"), itemscope: "itemscope", itemtype: "https://schema.org/ListItem", itemprop: "itemListElement")]
    if taxon
      crumbs << taxon.ancestors.reject{|i| i.parent == nil || i.level == 2}.collect { |ancestor| content_tag(:li, content_tag(:span, link_to(content_tag(:span, ancestor.name, itemprop: "name"), seo_url(ancestor), itemprop: "url") + separator, itemprop: "item"), itemscope: "itemscope", itemtype: "https://schema.org/ListItem", itemprop: "itemListElement") } unless taxon.ancestors.empty?
      crumbs << content_tag(:li, content_tag(:span, link_to(content_tag(:span, taxon.name, itemprop: "name") , seo_url(taxon), itemprop: "url"), itemprop: "item"), class: 'active', itemscope: "itemscope", itemtype: "https://schema.org/ListItem", itemprop: "itemListElement")
    else
      crumbs << content_tag(:li, content_tag(:span, Spree.t(:products), itemprop: "item"), class: 'active', itemscope: "itemscope", itemtype: "https://schema.org/ListItem", itemprop: "itemListElement")
    end

    crumb_list = content_tag(:ol, raw(crumbs.flatten.map{|li| li.mb_chars}.join)+ postfix.html_safe, class: 'breadcrumb', itemscope: "itemscope", itemtype: "https://schema.org/BreadcrumbList")
    content_tag(:nav, crumb_list, id: 'breadcrumbs', class: 'col-md-12')
  end




  def nested_li(objects, &block)
    objects = objects.reorder(:lft) if objects.is_a? Class

    return '' if objects.size == 0

    output = "<ul class='menu-sidebar nested-li'><li>"
    path = [nil]

    objects.each_with_index do |o, i|
      if o[:parent_id] != path.last
        # We are on a new level, did we descend or ascend?
        if path.include?(o[:parent_id])
          # Remove the wrong trailing path elements
          while path.last != o[:parent_id]
            path.pop
            output << '</li></ul>'
          end
          output << '</li><li>'
        else
          path << o[:parent_id]
          output << '<ul><li>'
        end
      elsif i != 0
        output << '</li><li>'
      end
      output << capture(o, path.size - 1, &block)
    end

    output << '</li></ul>' * path.length
    output.html_safe
  end


  def categories_tree(root_taxon, max_level = 1)
    return '' if max_level < 1 || root_taxon.children.empty?
    content_tag :ul, class: 'main-menu' do
      root_taxon.children.active.map do |taxon|
        content_tag :li do
          link_to(taxon.name, seo_url(taxon))
        end
      end.join("\n").html_safe
    end
  end

  def taxons_home_thumbnail(root_taxon)
    return '' if root_taxon.nil? || !root_taxon.icon.exists?


    concat(link_to seo_url(root_taxon), :class => 'link') do
      content_tag :div, class: "home-section on-height" do
        content_tag :div, class: "img-overlay" do
          concat("<img data-original='#{root_taxon.icon.url(:original)}' class='deferred_img' width='#{width}' height='#{height}'>".to_s.html_safe)
          concat(content_tag :h3, root_taxon.name)
        end
      end
    end

  end


  # Returns style of image or nil
  def create_product_image_tag(image, product, options, style)

    options.reverse_merge! alt: image.alt.blank? ? product.name : image.alt

    if options[:lazy]
      options['data-original'] = image.attachment.url(style)
      options[:class] = 'deferred_img'
      image_tag "noimage/#{style}.png", options
    else
      image_tag image.attachment.url(style), options
    end
  end

  def define_image_method(style)
    self.class.send :define_method, "#{style}_image" do |product, *options|
      options = options.first || {}
      if product.images.empty?
        if !product.is_a?(Spree::Variant) && !product.variant_images.empty?
          create_product_image_tag(product.variant_images.first, product, options, style)
        else
          if product.is_a?(Spree::Variant) && !product.product.variant_images.empty?
            create_product_image_tag(product.product.variant_images.first, product, options, style)
          else
            image_tag "noimage/#{style}.png", options
          end
        end
      else
        create_product_image_tag(product.images.first, product, options, style)
      end
    end
  end

end
