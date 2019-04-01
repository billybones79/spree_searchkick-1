module Spree
  module Core
    class OvFilter < Spree::Core::BaseFilter
      @@all_ov_filters = []

      def self.all_ov
        @@all_ov_filters
      end

      def ov_conds(option)
        conds = []
        tmpconds = {}
        option.each do |val|
          tmpconds[val.maybe_search_presentation] ||=[]
          tmpconds[val.maybe_search_presentation] << { match: { :color => val.id.to_s } }
        end
        tmpconds.each do |i, v|
          conds << [i, v ]
        end
        Hash[conds]
      end

      def ov_labels(option)
        labels = {}
        option.sort_by(&:maybe_search_presentation).each do |c|
          unless labels[c.maybe_search_presentation]
            if c[:alternate_presentation]
              labels[c.maybe_search_presentation] =  ["<span class = 'color' style='background-color:#{c.alternate_presentation}'></span><span>"+c.maybe_search_presentation+'</span>' , c.maybe_search_presentation]
            else
              labels[c.maybe_search_presentation] =  ["<span>"+c.maybe_search_presentation+'</span>' , c.maybe_search_presentation]
            end
          end
        end
        labels.values
      end

      def initialize(name, option)
        @name = Spree.t(name)
        @field_name = name
        @type = :ov_select
        @scope= name
        @labels = ov_labels(option)
        @conds = ov_conds(option)
        @blank_label = I18n.t('filters.all_#{name}')
        @@all_ov_filters.each do |filters|
          return if filters[:field_name] == name
        end
        @@all_ov_filters << self.filter
      end

      def self.color_filter
       self.new(:colors, Spree::OptionValue.includes(:translations).colors.reorder(:search_presentation).order(:presentation).all)
      end

      def self.size_filter
        self.new(:size, Spree::OptionValue.sizes.includes(:translations).all)
      end

    end
  end
end