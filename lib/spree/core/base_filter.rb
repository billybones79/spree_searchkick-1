module Spree
  module Core
      class BaseFilter
        attr_accessor :name, :field_name, :scope, :type, :conds, :blank_label

        def self.all_filters
          OvFilter.all_ov.push(*TxFilter.all_tx)
        end

        def filter
          {
              name: @name,
              field_name: @field_name,
              labels: @labels,
              scope: @scope,
              type: @type,
              conds: @conds,
              blank_label: @blank_label,
          }
        end

      end
  end
end
