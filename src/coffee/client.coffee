# emojidex coffee client
# * Provides search, index caching and combining and asset URI resolution
#
# =LICENSE=
# Licensed under the emojidex Open License
# https://www.emojidex.com/emojidex/emojidex_open_license
#
# Copyright 2013 Genshin Souzou Kabushiki Kaisha

class @EmojidexClient
  constructor: (opts = {}) ->

    # test = new Test
    # test.log "test test test"

    @_init_base_opts(opts)
    @_auto_login()
    # short-circuit next()
    @next = () ->
      null

  # sets global default values
  _init_base_opts: (opts) ->
    @defaults =
      locale: 'en'
      api_url: 'https://www.emojidex.com/api/v1/'
      cdn_url: 'http://cdn.emojidex.com/emoji'
      closed_net: false
      min_query_len: 4
      size_code: 'px32'
      detailed: false
      limit: 32
    opts = $.extend {}, @defaults, opts

    # set closed network flag (for OSS distrobutions, intranet/private neworks, or closed license)
    # DO NOT set to true unless permitted by an emojidex License
    @closed_net = opts.closed_net

    # set end points
    @api_url = opts.api_url
    @cdn_url = opts.cdn_url
    @size_code = opts.size_code

    # common opts
    @detailed = opts.detailed
    @limit = opts.limit

    # init storage and state instances
    @_init_storages(opts)
    @results = opts.results || []
    @cur_page = opts.page || 1
    @cur_limit = @limit
    @count = opts.count || 0

  # initializes local storages and/or syncs with instance variables
  _init_storages: (opts) ->
    @storage = $.localStorage

    @storage.set("emojidex", {}) unless @storage.isSet("emojidex")

    @storage.set("emojidex.emoji", opts.emoji || []) unless @storage.isSet("emojidex.emoji")
    @emoji = @storage.get("emojidex.emoji")

    @storage.set("emojidex.history", opts.history || []) unless @storage.isSet("emojidex.history")
    @history = @storage.get("emojidex.history")

    @storage.set("emojidex.favorites", opts.favorites || []) unless @storage.isSet("emojidex.favorites")
    @favorites = @storage.get("emojidex.favorites")

    @storage.set("emojidex.categories", opts.categories || []) unless @storage.isSet("emojidex.categories")
    @categories = @storage.get("emojidex.categories")

    @_pre_cache(opts)

  _pre_cache: (opts) ->
    if @emoji.length == 0
      switch opts.locale
        when 'en'
          @user_emoji('emoji')
          @user_emoji('emojidex')
        when 'ja'
          @user_emoji('絵文字')
          @user_emoji('絵文字デックス')

    if @categories.length == 0
      @get_categories(null, {locale: opts.locale})

  # Checks for local saved login data, and if present sets the username and api_key
  _auto_login: () ->
    return if @closed_net
    if @storage.get("emojidex.auth_token")?
      @auth_status = @storage.get("emojidex.auth_status")
      @auth_token = @storage.get("emojidex.auth_token")
      @user = @storage.get("emojidex.user")
      @get_user_data()
    else
      @logout()

  # Executes a general search (code_cont)
  search: (term, callback = null, opts) ->
    @next = () ->
      @search(term, callback, $.extend(opts, {page: opts.page + 1}))
    opts = @_combine_opts(opts)
    if term.length >= @defaults.min_query_len && !@closed_net
      $.getJSON((@api_url +  'search/emoji?' + $.param(($.extend {}, \
          {code_cont: @_escape_term(term)}, opts))))
        .error (response) =>
          @results = []
        .success (response) =>
          @_succeed(response, callback)
    else
      @local_search(term, callback)
    @local_search(term)

  local_search: (term, callback = null) ->
    res = (moji for moji in @emoji when @emoji.code.match('.*' + term + '.*/i'))
    callback(res) if callback

  # Executes a search starting with the given term
  search_sw: (term, callback = null, opts) ->
    @next = () ->
      @search_sw(term, callback, $.extend(opts, {page: opts.page + 1}))
    opts = @_combine_opts(opts)
    $.getJSON((@api_url +  'search/emoji?' + $.param(($.extend {}, \
        {code_sw: @_escape_term(term)}, opts))))
      .error (response) =>
        @results = []
      .success (response) =>
        @_succeed(response, callback)

  # Executes a search ending with the given term
  search_ew: (term, callback = null, opts) ->
    @next = () ->
      @search_ew(term, callback, $.extend(opts, {page: opts.page + 1}))
    opts = @_combine_opts(opts)
    $.getJSON((@api_url +  'search/emoji?' + $.param(($.extend {}, \
        {code_ew: @_escape_term(term)}, opts))))
      .error (response) =>
        @results = []
      .success (response) =>
        @_succeed(response, callback)

  # Searches by a tag
  tag_search: (tags, callback = null, opts) ->
    @next = () ->
      @tag_search(term, callback, $.extend(opts, {page: opts.page + 1}))
    opts = @_combine_opts(opts)
    $.getJSON((@api_url +  'search/emoji?' + $.param(($.extend {}, \
        {"tags[]": @_breakout(tags)}, opts))))
      .error (response) =>
        @results = []
      .success (response) =>
        @_succeed(response, callback)

  # Searches using an array of keys and an array of tags
  advanced_search: (term, tags = [], categories = [], callback = null, opts) ->
    @next = () ->
      @advanced_search(term, tags, categories, callback, $.extend(opts, {page: opts.page + 1}))
    opts = @_combine_opts(opts)
    params = {code_cont: @_escape_term(term)}
    params = $.extend(params, {"tags[]": @_breakout(tags)}) if tags.length > 0
    params = $.extend(params, {"categories[]": @_breakout(categories)}) if categories.length > 0
    $.getJSON((@api_url +  'search/emoji?' + $.param(($.extend params, opts))))
      .error (response) =>
        @results = []
      .success (response) =>
        @_succeed(response, callback)

  # Obtains a user emoji collection
  user_emoji: (username, callback = null, opts) ->
    opts = @_combine_opts(opts)
    $.getJSON((@api_url +  'users/' + username + '/emoji?' + $.param(opts)))
      .error (response) =>
        @results = []
      .success (response) =>
        @_succeed(response, callback)

  get_index: (callback = null, opts) ->
    @next = () ->
      @get_index(callback, $.extend(opts, {page: opts.page + 1}))
    opts = @_combine_opts(opts)
    $.getJSON((@api_url + '/emoji?' + $.param(opts)))
      .error (response) =>
        @results = []
      .success (response) =>
        @_succeed(response, callback)

  get_newest: (callback = null, opts) ->
    @next = () ->
      @get_newest(callback, $.extend(opts, {page: opts.page + 1}))
    opts = @_combine_opts(opts)
    $.getJSON((@api_url + '/newest?' + $.param(opts)))
      .error (response) =>
        @results = []
      .success (response) =>
        @_succeed(response, callback)

  get_popular: (callback = null, opts) ->
    @next = () ->
      @get_popular(callback, $.extend(opts, {page: opts.page + 1}))
    opts = @_combine_opts(opts)
    $.getJSON((@api_url + '/popular?' + $.param(opts)))
      .error (response) =>
        @results = []
      .success (response) =>
        @_succeed(response, callback)

  # Gets the full list of caetgories available
  get_categories: (callback = null, opts) ->
    opts = @_combine_opts(opts)
    $.getJSON((@api_url +  'categories?' + $.param(opts)))
      .error (response) =>
        @categories = []
        @storage.set("emojidex.categories", @categories)
      .success (response) =>
        @categories = response.categories
        @storage.set("emojidex.categories", @categories)
        callback(response.categories) if callback

  # login
  # takes a hash with one of the following combinations:
  # 1. { authtype: 'plain', username: 'username-or-email', password: '****'}
  # 1. { authtype: 'basic', user: 'username-or-email', pass: '****'}
  # 3. { authtype: 'google', #TODO
  # * if no hash is given auto login is attempted
  login: (params) ->
    switch params.authtype
      when 'plain'
        @plain_auth(params.username, params.password, params.callback)
      when 'basic'
        @basic_auth(params.user, params.pass, params.callback)
      when 'google'
        @google_auth(params.callback)
      else
        @_auto_login()

  # logout:
  # 'logs out' by clearing user data
  logout: () ->
    @auth_status = 'none'
    @storage.set("emojidex.auth_status", @auth_status)
    @user = ''
    @storage.set("emojidex.user", @user)
    @auth_token = null
    @storage.set("emojidex.auth_token", @auth_token)

  # regular login with username/email and password
  plain_auth: (username, password, callback = null) ->
    url = @api_url + 'users/authenticate?' + $.param(username: username, password: password)
    $.getJSON(url)
      .error (response) =>
        @auth_status = response.auth_status
        @auth_token = null
        @user = ''
      .success (response) =>
        @_set_auth_from_response(response)
        callback(response.auth_token) if callback

  # auth with HTTP basic auth
  basic_auth: (user, pass, callback = null) ->
    # TODO
    return false

  # auth with google oauth2
  google_auth: (callback = null) ->
    return false

  # sets auth parameters from a successful auth request [login]
  _set_auth_from_response: (response) ->
    @auth_status = response.auth_status
    @storage.set("emojidex.auth_status", @auth_status)
    @auth_token = response.auth_token
    @storage.set("emojidex.auth_token", @auth_token)
    @user = response.auth_user
    @storage.set("emojidex.user", @user)
    @get_user_data()

  get_user_data: () ->
    @get_favorites()
    @get_history()

  get_history: (opts) ->
    if @auth_token?
      $.getJSON((@api_url +  'users/history?' + $.param({auth_token: @auth_token})))
        .error (response) =>
          @history = []
        .success (response) =>
          @history = response

  set_history: (emoji_code) ->
    if @auth_token?
      $.post(@api_url + 'users/history?' + \
        $.param({auth_token: @auth_token, emoji_code: emoji_code}))

  get_favorites: (callback) ->
    if @auth_token?
      $.ajax
        url: @api_url + 'users/favorites'
        data:
          auth_token: @auth_token

        success: (response) =>
          @favorites = response
          callback(@favorites) if callback?

        error: (response) =>
          @favorites = []

  set_favorites: (emoji_code, callback) ->
    if @auth_token?
      $.ajax
        type: 'POST'
        url: @api_url + 'users/favorites'
        data:
          auth_token: @auth_token
          emoji_code: emoji_code

        success: (response) =>
          @get_favorites() # re-obtain favorites
          callback(@favorites) if callback?

  unset_favorites: (emoji_code) ->
    if @auth_token?
      $.ajax
        type: 'DELETE'
        url: @api_url + 'users/favorites'
        data:
          auth_token: @auth_token
          emoji_code: emoji_code

        success: (response) ->
          # @get_favorites()

  # Concatenates and flattens the given emoji array into the @emoji array
  combine_emoji: (emoji) ->
    $.extend @emoji, emoji

  # Converts an emoji array to [{code: "moji_code", img_url: "http://cdn...moji_code.png}] format
  simplify: (emoji = @results, size_code = @size_code) ->
    ({code: @_escape_term(moji.code), img_url: "#{@cdn_url}/#{size_code}/#{@_escape_term(moji.code)}.png"} \
      for moji in emoji)

  # Combines opts against common defaults
  _combine_opts: (opts) ->
    $.extend {}, { page: 1, limit: @limit, detailed: @detailed }, opts

  # fills in @results, @cur_page, and @count and calls callback
  _succeed: (response, callback) ->
    @results = response.emoji
    @cur_page = response.meta.page
    @count = response.meta.count
    @combine_emoji(response.emoji)
    callback(response.emoji) if callback

  # Breakout into an array
  _breakout: (items) ->
    return [] if items == null
    items = [items] unless items instanceof Array
    items

  # Escapes spaces to underscore
  _escape_term: (term) ->
    term.split(' ').join('_')

  # De-Escapes underscores to spaces
  _de_escape_term: (term) ->
    term.split('_').join(' ')
