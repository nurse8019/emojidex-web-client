class EmojidexData {
  constructor(EC, options) {
    this.EC = EC;
    this.options = options;
    this._def_auth_info = {
      status: 'none',
      user: '',
      token: null,
      r18: false,
      premium: false,
      premium_exp: null,
      pro: false,
      pro_exp: null
    };

    if (this.options.storageHubPath != null) {
      this.storage = new EmojidexDataStorage(this.options.storageHubPath);
    } else {
      this.storage = new EmojidexDataStorage();
    }

    return this.storage.hub.onReadyFrame().then( () => {
      return this.storage.hub.onConnect();
    }
    ).then( () => {
      return this.storage.hub.getKeys();
    }
    ).then(keys => {
      if (keys.indexOf('emojidex') !== -1) {
        return this.storage.update_cache('emojidex');
      } else {
        this.storage.hub_cache = {
          emojidex: {
            //moji_codes: @EC.options.moji_codes || {emoji_string: "", emoji_array: [], emoji_index: {}}
            moji_codes: {
              emoji_string: "",
              emoji_array: [],
              emoji_index: {}
            },
            emoji: this.EC.options.emoji || [],
            history: this.EC.options.history || [],
            favorites: this.EC.options.favorites || [],
            categories: this.EC.options.categories || [],
            auth_info: this.EC.options.auth_info || this._def_auth_info
          }
        };
        return this.storage.update('emojidex', this.storage.hub_cache.emojidex);
      }
    }
    ).then(data => {
      if (this.storage.hub_cache.emojidex.cdn_url != null) {
        return this.EC.cdn_url = this.storage.get('emojidex.cdn_url');
      } else {
        // if the CDN URL has not been overridden
        // attempt to get it from the api env
        if (this.EC.cdn_url === this.EC.defaults.cdn_url && this.EC.closed_net === false) {
          return $.ajax({
            url: this.EC.api_url + "/env",
            dataType: 'json'
          }).then(response => {
            this.EC.env = response;
            this.EC.cdn_url = `https://${this.EC.env.s_cdn_addr}/emoji/`;
            return this.storage.update('emojidex', {cdn_url: this.EC.cdn_url});
          }
          );
        }
      }
    }
    ).then(data => {
      return this.EC.Data = this;
    }
    );
  }

  moji_codes() {
    return this.storage.hub_cache.emojidex.moji_codes;
  }

  emoji(emoji_set) {
    if (emoji_set != null) {
      if (this.storage.hub_cache.emojidex.emoji.length > 0) {
        let hub_emoji = this.storage.hub_cache.emojidex.emoji;
        for (let i = 0; i < emoji_set.length; i++) {
          let new_emoji = emoji_set[i];
          for (let j = 0; j < hub_emoji.length; j++) {
            let emoji = hub_emoji[j];
            if (new_emoji.code === emoji.code) {
              hub_emoji.splice(hub_emoji.indexOf(emoji), 1, new_emoji);
              break;
            } else if (emoji === hub_emoji[hub_emoji.length - 1]) {
              hub_emoji.push(new_emoji);
            }
          }
        }
        return this.storage.update('emojidex', {emoji: hub_emoji});
      } else {
        return this.storage.update('emojidex', {emoji: emoji_set});
      }
    } else if (this.storage.hub_cache.emojidex.emoji != null) {
      return this.storage.hub_cache.emojidex.emoji;
    } else {
      return undefined;
    }
  }

  favorites(favorites_set) {
    if (favorites_set != null) { return this.storage.update('emojidex', {favorites: favorites_set}); }
    return this.storage.hub_cache.favorites;
  }

  history(history_set) {
    if (history_set != null) { return this.storage.update('emojidex', {history: history_set}); }
    return this.storage.hub_cache.history;
  }

  categories(categories_set) {
    if (categories_set != null) { return this.storage.update('emojidex', {categories: categories_set}); }
    return this.storage.hub_cache.categories;
  }

  auth_info(auth_info_set) {
    if (auth_info_set != null) {
      this.EC.User.auth_info = auth_info_set;
      return this.storage.update('emojidex', {auth_info: auth_info_set});
    }
    return this.storage.hub_cache.auth_info;
  }
}
