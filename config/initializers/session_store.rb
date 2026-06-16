Rails.application.config.session_store :cache_store,
  key: "_action_note_api_session",
  expire_after: 1.month
