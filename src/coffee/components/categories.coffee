class EmojidexCategories
  constructor: (shared = null) ->
    @S = shared || new EmojidexShared
    @_categories = @S.Data.categories()

    if @S.Data.categories().length == 0
      @sync()

  # Gets the full list of caetgories available
  sync: (callback = null, locale = null) ->
    locale = @S.locale unless locale
    $.getJSON((@S.api_url +  'categories?' + $.param({locale: locale})))
      .success (response) =>
        @_categories = @S.Data.categories(response.categories)
        callback(response.categories) if callback

  all: () ->
    @_categories