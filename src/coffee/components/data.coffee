class EmojidexData
  constructor: (opts) ->
    @storage = $.localStorage
    @storage.set("emojidex", {}) unless @storage.isSet("emojidex")
    @storage.set("emojidex.emoji", opts.emoji || []) unless @storage.isSet("emojidex.emoji")
    @storage.set("emojidex.history", opts.history || []) unless @storage.isSet("emojidex.history")
    @storage.set("emojidex.favorites", opts.favorites || []) unless @storage.isSet("emojidex.favorites")
    @storage.set("emojidex.auth_info", opts.auth_info || @_def_auth_info()) unless @storage.isSet("emojidex.auth_info")

  emoji: (emoji_set = null) ->
    @storage.set("emojidex.emoji", emoji_set) if emoji_set != null
    @storage.get("emojidex.emoji")

  favorites: (favorites_set = null) ->
    @storage.set("emojidex.favorites", favorites_set) if favorites_set != null
    @storage.get("emojidex.favorites")

  history: (history_set = null) ->
    @storage.set("emojidex.history", history_set) if history_set != null
    @storage.get("emojidex.history")

  categories: (categories_set = null) ->
    @storage.set("emojidex.categories", categories_set) if categories_set != null
    @storage.get("emojidex.categories")

  _def_auth_info: () ->
    {status: 'none', user: '', token: null}

  auth_info: (auth_info_set = null) ->
    @storage.set("emojidex.auth_info", auth_info_set) if auth_info_set != null
    @storage.get("emojidex.auth_info")