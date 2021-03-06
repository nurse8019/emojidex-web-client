export default class EmojidexUserHistory {
  constructor(EC) {
    this.EC = EC;
    this._history = this.EC.Data.history();
    this.cur_page = 1;
    this.max_page = undefined;
  }

  _historyAPI(options) {
    if (this.EC.User.auth_info.token != null) {
      let ajax_obj = {
        url: this.EC.api_url + 'users/history',
        dataType: 'json'
      };
      return $.ajax($.extend(ajax_obj, options));
    }
  }

  get(callback, page = 1) {
    let options = {
      data: {
        page: page,
        limit: this.EC.limit,
        detailed: this.EC.detailed,
        auth_token: this.EC.User.auth_info.token
      },
      url: this.EC.api_url + 'users/history/emoji'
    };
    return this._historyAPI(options).then((response) => {
      this._history = response.emoji;
      this.meta = response.meta;
      this.cur_page = response.meta.page;
      this.max_page = Math.ceil(response.total_count / this.EC.limit);

      return this.EC.Data.history(this._history);
    }).then(() => {
      if (typeof callback === 'function') {
        callback(this._history);
      } else {
        return this._history;
      }
    });
  }

  getHistoryInfoOnly(callback, page = 1) {
    let options = {
      data: {
        page: page,
        limit: this.EC.limit,
        detailed: this.EC.detailed,
        auth_token: this.EC.User.auth_info.token
      }
    };
    return this._historyAPI(options).then((response) => {
      this._history_info = response.history;
      this.history_info_meta = response.meta;
      this.history_info_cur_page = response.meta.page;
      this.history_info_max_page = Math.ceil(response.total_count / this.EC.limit);

      if (typeof callback === 'function') {
        callback(this._history_info);
      } else {
        return this._history_info;
      }
    });
  }

  set(emoji_code) {
    let options = {
      type: 'POST',
      data: {
        auth_token: this.EC.User.auth_info.token,
        emoji_code
      },
      success: response => {
        for (let i = 0; i < this._history.length; i++) {
          let entry = this._history[i];
          if (entry.emoji_code === response.emoji_code) {
            this._history[i] = response;
            this.EC.Data.history(this._history);
            return;
          }
        }
        return response;
      }
    };
    return this._historyAPI(options);
  }

  sync() {
    return this.get();
  }

  all(callback) {
    return this.EC.Data.history().then(data => {
      if (typeof callback === 'function') {
        callback(data);
      } else {
        return data;
      }
    });
  }

  next(callback) {
    if (this.max_page === this.cur_page) return;
    return this.get(callback, this.cur_page + 1);
  }

  prev(callback) {
    if (this.cur_page === 1) return;
    return this.get(callback, this.cur_page - 1);
  }
}
