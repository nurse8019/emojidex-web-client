describe('EmojidexUtil', function() {
  beforeEach(function(done) {
    helperChains({
      functions: [helperBefore],
      end: done
    });
  });

  it('escapes a term with escapeTerm', function() {
    expect(EC_spec.Util.escapeTerm('emoji kiss')).toBe('emoji_kiss');
  });

  it('de-escapes a term with deEscapeTerm', function() {
    expect(EC_spec.Util.deEscapeTerm('emoji_kiss')).toBe('emoji kiss');
  });

  it('encapsulates a code with colons', function() {
    expect(EC_spec.Util.encapsulateCode('my code')).toBe(':my code:');
    expect(EC_spec.Util.encapsulateCode(':my code:')).toBe(':my code:');
  });

  it('un-encapsulates a code with colons', function() {
    expect(EC_spec.Util.unEncapsulateCode(':my code:')).toBe('my code');
  });

  it('simplifies an emoji object array for easy processing with simplify', function() {
    let emoji = EC_spec.Util.simplify([emoji_kissing]);
    expect(emoji[0].code).toBe('kissing');
    expect(emoji[0].img_url).toBe(`${EC_spec.cdn_url}/${EC_spec.size_code}/${emoji[0].code}.png`);
  });

  it('converts an emoji object into an HTML tag set', done => 
    EC_spec.Search.find('red_car', function(emoji) {
      expect(EC_spec.Util.emojiToHTML(emoji)).toBe(
        "<img src='http://cdn.emojidex.com/emoji/px32/red_car.png' emoji-code='red_car' emoji-moji='🚗' alt='red car' />");
      done();
    })
  );

  it('converts an emoji object into an HTML tag set with link', done =>
    EC_spec.Search.find('emojidex', function(emoji) {
      expect(EC_spec.Util.emojiToHTML(emoji)).toBe(
          "<a href='https://www.emojidex.com' emoji-code='emojidex'><img src='http://cdn.emojidex.com/emoji/px32/emojidex.png' emoji-code='emojidex' alt='emojidex' /></a>");
      done();
    })
  );


  it('converts an emoji object into a Markdown snippet', done =>
    EC_spec.Search.find('red_car', function(emoji) {
      expect(EC_spec.Util.emojiToMD(emoji)).toBe(
        '![🚗](http://cdn.emojidex.com/emoji/px32/red_car.png "red car")');
      done();
    })
  );

  it('converts an emoji object into a Markdown snippet with link', done =>
    EC_spec.Search.find('emojidex', function(emoji) {
      expect(EC_spec.Util.emojiToMD(emoji)).toBe(
          '[![emojidex](http://cdn.emojidex.com/emoji/px32/emojidex.png "emojidex") ](https://www.emojidex.com)');
      done();
    })
  );

  it('converts text with emoji html in it to plain text with emoji short codes', function() {
    test_text = "Test text <img src='http://cdn.emojidex.com/emoji/px32/red_car.png' "
      + "emoji-code='red_car' emoji-moji='🚗' alt='red car' />テスト<a href='https://www.emojidex.com' "
      + "emoji-code='emojidex'><img src='http://cdn.emojidex.com/emoji/px32/emojidex.png' "
      + "emoji-code='emojidex' alt='emojidex' /></a><img src='http://cdn.emojidex.com/emoji/px32/red_car.png' />";

    expected_text =  "Test text 🚗テスト:emojidex:<img src='http://cdn.emojidex.com/emoji/px32/red_car.png' />";

    expect(EC_spec.Util.deEmojifyHTML(test_text)).toBe(expected_text);
  });
});
