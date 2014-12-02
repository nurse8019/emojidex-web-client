class EmojisLoaderAPI extends EmojisLoader
  constructor: (@element, @options) ->
    super

  load: (callback)->
    onLoadEmojisData = (emojis_data) =>
      console.dir emojis_data
      # fix data for At.js --------
      for emoji in emojis_data
        emoji.code = emoji.id
        emoji.img_url = "http://assets.emojidex.com/emoji/px16/#{emoji.cod}.png"

      @emojis_data = @getCategorizedData emojis_data
      @emoji_regexps = @setEmojiCSS_getEmojiRegexps @emojis_data
      @setEmojiIcon @
      callback @

    # start main --------
    @getEmojiDataFromAPI onLoadEmojisData
    @

  getEmojiDataFromAPI: (callback) ->
    loaded_num = 0
    user_names = ["emojidex", "emoji"]
    emojis_data = []

    for user_name in user_names
      $.ajaxSetup beforeSend: (jqXHR, settings) ->
        # set user_name for loaded flag --------
        jqXHR.user_name = user_name

      $.ajax
        url: "https://www.emojidex.com/api/v1/users/" + user_name + "/emoji"
        dataType: "json"
        type: "get"

        success: (user_emojis_json, status, xhr) ->
          # console.log "success: load json"
          emojis_data = emojis_data.concat user_emojis_json.emoji
          if ++loaded_num is user_names.length
            set_emoji_list emojis_data

          callback emojis_data
          return
        error: (data) ->
          console.log "error: load json"
          console.log data
          return