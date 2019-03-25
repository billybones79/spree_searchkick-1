
Deface::Override.new(
    :virtual_path => 'spree/products/index',
    :name => 'add_search_filters_products',
    :insert_top => "div[data-hook= 'homepage_sidebar_navigation']",
    :text => "<%= render :partial => 'spree/shared/search_filters' %>",
)

