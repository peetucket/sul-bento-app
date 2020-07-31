# frozen_string_literal: true

module QuickSearch
  class LibGuidesSearcher < QuickSearch::Searcher
    delegate :results, :total, :facets, to: :@response

    def search
      @response ||= ::LibGuidesSearchService.new.search(q)
    end

    def loaded_link
      format(Settings.LIBGUIDES.QUERY_URL.to_s, q: CGI.escape(q.to_s))
    end
  end
end
