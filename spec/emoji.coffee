describe 'EmojidexEmoji', ->
  beforeAll (done) ->
    helperChains
      functions: [helperBefore]
      end: done

  # describe 'check update', ->
  #   it 'need update', (done) ->
  #     EC_spec.Data.storage.update('emojidex.seedUpdated', new Date('1/1/2016').toString()).then =>
  #       expect(EC_spec.Emoji.checkUpdate()).toBe(true)
  #       done()
  #
  #   it 'unnecessary update', (done) ->
  #     EC_spec.Data.storage.update('emojidex.seedUpdated', new Date().toString()).then =>
  #       expect(EC_spec.Emoji.checkUpdate()).toBe(false)
  #       done()
  #
  # it 'seed', (done) ->
  #   EC_spec.Indexes.static ['utf_emoji', 'extended_emoji'], 'en', (emoji_data) ->
  #     expect(EC_spec.Emoji._emoji_instance).toEqual(jasmine.arrayContaining [emoji_data[0], emoji_data[emoji_data.length - 1]])
  #     done()
  #
  # it 'all', (done) ->
  #   expect(EC_spec.Emoji.all().length).toBeTruthy()
  #   done()
  #
  # it 'search', (done) ->
  #   EC_spec.Emoji.search 'kissing', (emoji_data) ->
  #     expect(emoji_data).toContain(jasmine.objectContaining emoji_kissing)
  #     done()
  #
  # it 'starting', (done) ->
  #   EC_spec.Emoji.starting 'kiss', (emoji_data) ->
  #     expect(emoji_data).toContain(jasmine.objectContaining emoji_kiss)
  #     done()
  #
  # it 'ending', (done) ->
  #   EC_spec.Emoji.ending 'kiss', (emoji_data) ->
  #     expect(emoji_data).toContain(jasmine.objectContaining emoji_kiss)
  #     done()
  #
  # it 'tags', ->
  #   expect(EC_spec.Emoji.tags('weapon').length).toBeTruthy()
  #
  # it 'categories', ->
  #   expect(EC_spec.Emoji.categories('cosmos').length).toBeTruthy()
  #
  # it 'advenced', ->
  #   searchs = categories: 'tools', tags: 'weapon', term: 'rifle'
  #   expect(EC_spec.Emoji.advanced(searchs).length).toBeTruthy()
  #
  it 'flush', ->
    expect(EC_spec.Emoji.flush().length).toBe(0)
