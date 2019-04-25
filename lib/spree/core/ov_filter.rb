module Spree
  module Core
    class OvFilter < Spree::Core::BaseFilter

      def ov_conds(name, option)
        conds = []
        tmpconds = {}
        option.each do |val|
          tmpconds[val.maybe_search_presentation] ||=[]
          tmpconds[val.maybe_search_presentation] << { match: { name => val.id.to_s } }
        end
        tmpconds.each do |i, v|
          conds << [i, v ]
        end
        Hash[conds]
      end

      def ov_labels(option)
        labels = {}
        ot = Spree::OptionType.where(id: option.first[:option_type_id]).first
        sorted_ov =  option.sort_by( &(ot[:sorted_by_position] ? :position : :maybe_search_presentation))
        sorted_ov.each do |c|
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
        @conds = ov_conds(name, option)
        @blank_label = I18n.t("filters.all_#{name}")
      end

      def self.all_ov
        all_ov_filters = []
        Spree::OptionType.all.each do |ot|
          all_ov_filters << self.new(ot[:presentation].downcase.to_sym, Spree::OptionValue.includes(:translations).where(:option_type_id => ot[:id]).all).filter
        end
        all_ov_filters
      end
    end
  end
end