class EmojidexEmoji
  constructor: (@EC) ->
    @_emoji_instance = []

  _emoji: ->
    return @_emoji_instance if @_emoji_instance?

    if @checkUpdate()
      @EC.Data.storage.update 'emojidex.seedUpdated', new Date().toString()
      @seed()
    else
      @_emoji_instance = @EC.Data.storage.get 'emojidex.emoji'

  checkUpdate: ->
    if @EC.Data.storage.isSet('emojidex.seedUpdated')
      current = new Date
      updated = new Date @EC.Data.storage.get('emojidex.seedUpdated')
      if current - updated >= 3600000 * 48
        return true
      else
        return false
    else
      return false

  # Gets the full list of caetgories available
  seed: (callback) ->
    @EC.Indexes.static ['utf_emoji', 'extended_emoji'], null, callback

  all: ->
    @_emoji()

  # internal collection search
  search: (term, callback) ->
    results = (moji for moji in @_emoji() when moji.code.match term)
    callback? results
    results

  # internal collection search (starting with)
  starting: (term, callback) ->
    results = (moji for moji in @_emoji() when moji.code.match '^' + term)
    callback? results
    results

  # internal collection search (starting with)
  ending: (term, callback) ->
    results = (moji for moji in @_emoji() when moji.code.match term + '$')
    callback? results
    results

  # search for emoji with the given tags
  tags: (tags, opts) ->
    tags = @EC.Util.breakout tags
    selection = opts?.selection || @_emoji()
    collect = []
    for tag in tags
      collect = collect.concat (moji for moji in selection when $.inArray(tag, moji.tags) >= 0)
    collect

  # gets emoji in any of the given categories
  categories: (categories, opts) ->
    categories = @EC.Util.breakout categories
    source = opts?.selection || @_emoji()
    collect = []
    for category in categories
      collect = collect.concat (moji for moji in source when moji.category is category)
    collect

  # searches by term (regex OK), containing the tags given, in any of the given categories
  advanced: (searchs) ->
    @categories(
      searchs.categories
      selection: @tags(searchs.tags, selection: @search searchs.term)
    )

  # Concatenates and flattens the given emoji array into the @emoji array
  combine: (emoji) =>
    @EC.Data.emoji(emoji).then (hub_data) =>
      @_emoji_instance = hub_data.emoji

  # Clears the emoji array and emoji in storage.
  # DO NOT call this unless you have a really good reason!
  flush: ->
    @EC.Data.storage.remove 'emojidex.emoji'
    @_emoji_instance = []
