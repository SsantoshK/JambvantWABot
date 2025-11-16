-- Jambvant DB schema: users and message logs

-- Users table: map phone numbers to user profiles
CREATE TABLE IF NOT EXISTS users (
  user_id SERIAL PRIMARY KEY,
  phone_number VARCHAR(32) NOT NULL UNIQUE,
  full_name VARCHAR(200),
  profile JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Optional facts/contexts table used by workflow
CREATE TABLE IF NOT EXISTS user_facts (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
  fact_text_english TEXT,
  importance_score INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Message logs: record Q&A mapped to user
CREATE TABLE IF NOT EXISTS message_logs (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(user_id) NULL,
  phone_number VARCHAR(32),
  input_text_hindi TEXT,
  stt_service VARCHAR(80),
  stt_confidence REAL,
  ai_service VARCHAR(80),
  ai_model VARCHAR(80),
  ai_prompt_tokens INTEGER,
  ai_completion_tokens INTEGER,
  response_text_english TEXT,
  response_text_hindi TEXT,
  tts_service VARCHAR(80),
  tts_audio_url TEXT,
  delivery_status VARCHAR(32),
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone_number);
CREATE INDEX IF NOT EXISTS idx_message_logs_user ON message_logs(user_id);
