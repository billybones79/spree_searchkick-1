module Spree
  module Core
    class TxFilter < Spree::Core::BaseFilter
      @@all_tx_filters = []

      def self.all_tx
        @@all_tx_filters
      end

      def tx_conds(taxons)
        conds = []
        taxons.each do |t|
          conds << [t.id.to_s, { match: { :taxon_ids => t.id } } ]
        end
        Hash[*conds.flatten]
      end

      def tx_labels(taxons)
        labels = []
        taxons.sort_by(&:name).each do |t|
          labels << ["<span>"+t.name+'</span>' , t.id]
        end
        labels.compact
      end

      def initialize(name, option)
        @name = Spree.t(name)
        @field_name = name
        @type = :select
        @scope= name
        @labels = tx_labels(option)
        @conds = tx_conds(option)
        @blank_label = I18n.t('filters.all_#{name}')
        @@all_tx_filters.each do |filters|
          return if filters[:field_name] == name
        end
        @@all_tx_filters << self.filter
      end

      def self.brand_filter
        taxonomy = Spree::Taxonomy.find(Rails.configuration.brand_id)
        self.new(:brand, taxonomy.root.leaves.includes(:translations))
      end

      def self.category_filter
        taxonomy = Spree::Taxonomy.find(Rails.configuration.category_id)
        self.new(:category, taxonomy.root.leaves.includes(:translations))
      end
    end
  end
end