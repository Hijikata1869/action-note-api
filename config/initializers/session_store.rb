Rails.application.config.session_store :redis_session_store,
  key: "_action_note_api_session",
  expire_after: 1.month,
  redis: {
    url: ENV.fetch("REDIS_URL", "redis://redis:6379/0")
  }
