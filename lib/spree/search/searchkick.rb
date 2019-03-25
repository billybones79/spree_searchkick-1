module Spree
  module Search
    class Searchkick < Spree::Core::Search::Base
    @@all_filters = nil
    class << self
      attr_accessor :configuration
    end

    def initialize(params)
      #self.pricing_options = Spree::Config.default_pricing_options
      @properties = {}
      prepare(params)
    end


    def reinitialize(params)
      #self.pricing_options = Spree::Config.default_pricing_options
      @properties = {}
      prepare(params)
    end
    def self.configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end

    class Configuration
      # Sample configurable_attribute
      attr_accessor :configurable_attribute

      def initialize
        @configurable_attribute = false
      end
    end

    def retrieve_products
      get_base_search
    end
    def select_clause
      if selector
         selector
      else
        "*"
      end
    end

    def where_clause
      # Default items for where_clause
      where_clause = {

      }

      where_clause.merge!({taxon_ids: taxon.id}) if taxon
      where_clause.merge!({taxon_ids: {all: taxons.map(&:id)}}) if taxons

      # Add search attributes from params[:search]
      add_search_attributes(where_clause)
    end

    protected

    def get_base_search
      # If a query is passed in, then we are only using the ElasticSearch DSL and don't care about any other options
      if query
        Spree::Product.search(query: query)
      else

        search_options = {
          # Set execute to false in case we need to modify the search before it is executed
          execute: false,
          select: select_clause,
          where:    where_clause,
          page:     page,
          order: order_clause,

        }
        if  @properties[:body_options]
          search_options.deep_merge!(body_options: @properties[:body_options])
        end
        if  @properties[:per_page]
          search_options.merge!(per_page: per_page)
        end
        search_options.merge!(fields: ["name_i18n.#{I18n.locale}","description_i18n.#{I18n.locale}" ])
        search_options.merge!(searchkick_options)
        search_options.deep_merge!(includes: includes_clause)

        if @properties[:keywords].blank?
          keywords_clause = "*"
        else
          keywords_clause= @properties[:keywords]
          search_options[:fields] = Spree::Product.search_fields
          search_options[:operator] ="or"
          search_options[:match] = :word_start
          search_options[:misspellings] = { below: 1 }
        end


        search = Spree::Product.search(keywords_clause, search_options)

        # Add any search filters passed in
        # Adding search filters modifies the search query, which is why we need to wait on executing it until after search query is modified
        search = add_search_filters(search)

        search.execute
      end
    end


    def add_search_attributes(query)
      return query unless search
      search.each do |name, scope_attribute|
        if scope_attribute != "false"
          query.merge!(Hash[name, scope_attribute])
        end
      end

      query
    end

    def add_search_filters(search)

      return search unless filters

      @@all_filters ||= Spree::Core::SearchkickFilters.all_filters

      checkbox_filters = {}
      # Stuff that goes directly in the query
      queries = []
      # Stuff that goes in the filter part of the query
      filter_items = []

      # Find filter method definition from filters passed in
      filters.to_a.each do |filter_param|
        search_filter, search_labels = filter_param
        filter = @@all_filters.find { |filter| filter[:field_name].to_s == search_filter.to_s }


        next if filter.nil?
        if filter[:type] == :checkbox
          checkbox_filters[search_filter.to_sym] =
              filter[:conds].find_all { |filter_condition| search_labels.include?(filter_condition.first) }
        elsif filter[:type] == :range || filter[:type] == :money
          search_labels = search_labels.map(&:to_i)
          filter_items << {
              bool: {
                  should:{
                    :range => {
                      filter[:scope] => {
                        'lte' => search_labels.max{|a,b| a.to_i <=> b.to_i}.to_i,
                        'gte' => search_labels.min{|a,b| a.to_i <=> b.to_i}.to_i
                      }
                    }
                  }
              }
            }

        elsif filter[:type] == :select || filter[:type] == :ov_select
          checkbox_filters[search_filter.to_sym] =
              filter[:conds].find_all { |filter_condition| search_labels.include?(filter_condition.first.to_s) }

        elsif filter[:type] == :multi_level_select

          filter_param[1][filter[:scope].to_s].keys[0].to_i



          filter_param[1][filter[:scope]].each do |k, v|
            v[filter[:scope2]].each do |k2, v2|
              filter[:conds][k.to_i][:values][k2.to_i][2].each do |must|
                filter_items << {
                    bool: {
                        should: must
                    }
                }
              end


            end
          end

        end
      end

      # Loop through the applicable filters, collect the conditions, and generate filter options
      checkbox_filters.each do |applicable_filter|
        filter_name, filter_details = applicable_filter
        filter_options = []
        filter_details.each do |details|
          label, conditions = details
          filter_options << conditions
        end

        # Add filter_options to filter_items for the conditions from an applicable_filter
        unless filter_options.empty?
          filter_items << {
            bool: {
              should: filter_options.flatten(1)
            }
          }
        end
      end


      # Set search_filters with filter_items defined above
      search_filters = {
        bool: {
          must: filter_items
        }
      }

      # Update the search query filter hash in order to process the additional filters as well as the base_search

      if search.body[:query][:bool][:must][:dis_max]
        search.body[:query][:bool][:must][:dis_max]||={}
        search.body[:query][:bool][:must][:dis_max][:queries] ||= []
        search.body[:query][:bool][:must][:dis_max][:queries] = search.body[:query][:bool][:must][:dis_max][:queries] + queries
      else
        search.body[:query][:bool][:must] =queries
      end

      search.body[:query][:bool][:filter].push(search_filters)

      # Update the search query filter hash in order to process the additional filters as well as the base_search
      search

    end

    def includes_clause
      includes_clause =  [ :variant_images, :taxons, :master_variant]
      master_clause = { master_variant: [ :prices]}
      master_clause[:master_variant] << :images if include_images
      includes_clause << master_clause
      includes_clause
    end

    def order_clause
      withelisted_ordering= ["price", "name", "available_on", "_score"]
      unless order
         return [{"_score"=>"desc"},{"available_on" => :desc}]
      end
      s = order.split(":")

      puts s.inspect

      if withelisted_ordering.include?(s[0])
        if (s[0] == "name")
          s[0] = "name_i18n_keyword.#{I18n.locale.to_s}"
        end
        [{s[0] => s[1]},{"available_on" => :desc}]

      else
        return {"name_i18n_keyword.#{I18n.locale.to_s}" => :asc}

      end
    end

    def prepare(params)
      @properties[:query] = params[:query].blank? ? nil : params[:query]
      @properties[:filters] = params[:filter].blank? ? nil : params[:filter]
      @properties[:fields] = params[:fields].blank? ? nil : params[:fields]
      @properties[:searchkick_options] = params[:searchkick_options].blank? ? {} : params[:searchkick_options].deep_symbolize_keys
      @properties[:taxons] = params[:taxons]
      @properties[:possible_answer_ids] = params[:possible_answer_ids]

      @properties[:order] = params[:order]
      @properties[:selector] = params[:selector]
      @properties[:body_options] = params[:body_options] || {}


      @properties[:taxon] = params[:taxon].blank? ? nil : Spree::Taxon.find(params[:taxon])
      @properties[:keywords] = params[:keywords]
      @properties[:search] = params[:search]
      @properties[:include_images] = params[:include_images]



      params = params.deep_symbolize_keys
      per_page = (params[:per_page] || 24).to_i
      if per_page > 0
        @properties[:per_page] = per_page
      else
        @properties[:per_page] = 0
      end
      @properties[:page] = (params[:page].to_i <= 0) ? 1 : params[:page].to_i
    end
    end
  end
end



















