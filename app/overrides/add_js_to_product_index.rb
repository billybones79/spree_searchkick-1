
Deface::Override.new(
    :virtual_path => 'spree/products/index',
    :name => 'add_js_to_products',
    :insert_before => "erb[silent]:contains('if params[:keywords]')",
    :text => "<script>
    if( $('select').length) {
        //:not(.hasCustomSelect) pour par customselecter en double
        setup_search_autocomplete();
        $('select:not(.hasCustomSelect)').customSelect();

    }
</script>",
)

