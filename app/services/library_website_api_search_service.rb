# frozen_string_literal: true

# Uses the Library Website API to search
class LibraryWebsiteApiSearchService < AbstractSearchService
  def initialize(options = {})
    options[:query_url] ||= Settings.LIBRARY_WEBSITE_JSON_API_URL.to_s
    options[:response_class] ||= Response
    super
  end

  class HighlightedFacetItem < AbstractSearchService::HighlightedFacetItem
    def facet_field_to_param
      "f[0]=#{CGI.escape(value)}"
    end
  end

  class Response < AbstractSearchService::Response
    HIGHLIGHTED_FACET_FIELD = 'format_facet'
    HIGHLIGHTED_FACET_CLASS = LibraryWebsiteApiSearchService::HighlightedFacetItem
    QUERY_URL = Settings.LIBRARY_WEBSITE_QUERY_API_URL.freeze

    def results
      Array.wrap(json['results']).first(3).collect do |doc|
        result = AbstractSearchService::Result.new
        result.title = doc['title']
        result.link = doc['url']
        result.description = doc['description']
        result
      end
    end

    def facets
      facet_response = [{
        'name' => HIGHLIGHTED_FACET_FIELD
      }]
      facet_response.first['items'] = json['facets']['items'].map do |facet|
        {
          'value' => facet['term']&.first,
          'label' => facet['label'],
          'hits' => facet['hits'],
        }
      end
      facet_response
    end

    def total
      nil
    end

    private

    def json
      # Force UTF-8 as the API returns BOM
      @json ||= JSON.parse(
        @body.gsub("\xEF\xBB\xBF".dup.force_encoding(Encoding::BINARY), '')
      )
    end
    
  end
end
