Deface::Override.new(
    virtual_path: 'spree/admin/option_types/_form',
    name: 'add_alternate_presentation_option_type',
    insert_bottom: "[data-hook=admin_option_type_form_fields]",
    partial: 'spree/admin/option_types/sorted_field',
)
