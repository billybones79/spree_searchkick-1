module Spree
  module Core
   module SearchkickFilters
      def self.all_filters
        filters = []
        # Find all methods that ends with '_filter'
        filter_methods = Spree::Core::SearchkickFilters.methods.find_all { |m| m.to_s.end_with?('_filter') }
        filter_methods.each do |filter_method|
          filters << Spree::Core::SearchkickFilters.send(filter_method)
        end
        filters
      end

      def SearchkickFilters.format_price(amount)
        Spree::Money.new(amount)
      end

      def SearchkickFilters.price_range_filter min = 0, max =nil
        # Exclude new vehicle prices

        # {"Under $1.00"=>{:range=>{:price=>{:lt=>1}}}}
        {
            name:   Spree.t(:price),
            field_name: :price_range,
            scope:  :price,
            type:  :range,
            max: max || Spree::Price.maximum('amount').ceil.to_s, # TODO - Use products categories max
            min: min,
            conds:  [],
            labels: []
        }
      end

      def SearchkickFilters.color_select_filter colors =nil

        unless colors
          colors = Spree::OptionValue.includes(:translations).colors.reorder(:search_presentation).order(:presentation).all
        end
        tmpconds = {}
        colors.each do |val|
          tmpconds[val.maybe_search_presentation] ||=[]
          tmpconds[val.maybe_search_presentation] << { match: { :color => val.id.to_s } }
        end
        conds = []
        tmpconds.each do |i, v|
          conds << [i, v ]

        end

        labels = {}
        colors.sort_by(&:maybe_search_presentation).each do |c|
          unless labels[c.maybe_search_presentation]
            labels[c.maybe_search_presentation] =  ["<span class = 'color' style='background-color:#{c.alternate_presentation}'></span><span>"+c.maybe_search_presentation+'</span>' , c.maybe_search_presentation]
          end
        end



        {
            name: Spree.t(:color),
            field_name: :color,
            scope: :color,
            type: :ov_select,
            labels: labels.values,

            conds: Hash[conds],
            blank_label: I18n.t('filters.all_colors')

        }
      end

      def SearchkickFilters.size_select_filter sizes = nil


        unless sizes
          sizes = Spree::OptionValue.sizes.includes(:translations).all
        end

        tmpconds = {}
        sizes.each do |val|
          tmpconds[val.maybe_search_presentation] ||=[]
          tmpconds[val.maybe_search_presentation] << { match: { :size => val.id.to_s } }
        end
        conds = []
        tmpconds.each do |i, v|
          conds << [i, v]

        end

        labels = {}
        sizes.sort_by(&:maybe_search_presentation).each do |s|
          unless labels[s.maybe_search_presentation]
            labels[s.maybe_search_presentation] =  ["<span>"+s.maybe_search_presentation+'</span>' , s.maybe_search_presentation]
          end
        end

        {
            name: Spree.t(:size),
            field_name: :size,
            scope: :taxon,
            scope2: :size,
            type: :ov_select,
            labels: labels.values,
            conds: Hash[conds],
            blank_label: I18n.t('filters.all_sizes')

        }
      end


      def SearchkickFilters.brand_filter taxons= nil
        unless taxons
          taxonomy = Spree::Taxonomy.find(Rails.configuration.brand_id)
          taxons = taxonomy.root.leaves.includes(:translations)
        end
        conds = []

        taxons.each do |t|

          conds << [t.id.to_s, { match: { :taxon_ids => t.id } } ]

        end

        labels = []
        taxons.sort_by(&:name).each do |t|
            labels << ["<span>"+t.name+'</span>' , t.id]
        end

        {
          name:   I18n.t('brands'),
          field_name: 'brand',
          scope:  :brand,
          type:  :select,
          labels: labels.compact,
          conds: Hash[*conds.flatten],
          blank_label: I18n.t('filters.all_brands')
        }
      end



      def SearchkickFilters.category_filter taxons= nil
        unless taxons
          taxonomy = Spree::Taxonomy.find(Rails.configuration.category_id)

          taxons = taxonomy.root.leaves.includes(:translations)
        end
        conds = []

        taxons.each do |t|

          conds << [t.id.to_s, { match: { :taxon_ids => t.id } } ]

        end

        labels = []
        taxons.sort_by(&:name).each do |t|
            labels << ["<span>"+t.name+'</span>' , t.id]
        end

        {
            name:   I18n.t('Categories'),
            field_name: 'category',
            scope:  :category,
            type:  :select,
            labels: labels.compact,
            conds: Hash[*conds.flatten],
            blank_label: I18n.t('filters.all_categories')
        }
      end

    end
  end
end
