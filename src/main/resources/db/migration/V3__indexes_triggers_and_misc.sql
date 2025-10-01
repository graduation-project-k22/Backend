-- V3__indexes_triggers_and_misc.sql

-- Indexes (common ones)


-- Function to set updated_at
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger for users
DROP TRIGGER IF EXISTS trg_users_set_updated_at ON users;
CREATE TRIGGER trg_users_set_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Attach trigger for post
DROP TRIGGER IF EXISTS trg_post_set_updated_at ON post;
CREATE TRIGGER trg_post_set_updated_at
    BEFORE UPDATE ON post
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Attach trigger for history_comment (it has updated_at)
DROP TRIGGER IF EXISTS trg_history_comment_set_updated_at ON history_comment;
CREATE TRIGGER trg_history_comment_set_updated_at
    BEFORE UPDATE ON history_comment
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Attach trigger for policy (it has updated_at)
DROP TRIGGER IF EXISTS trg_policy_set_updated_at ON policy;
CREATE TRIGGER trg_policy_set_updated_at
    BEFORE UPDATE ON policy
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Optional: small cleanup functions or additional indexes can be added here.
