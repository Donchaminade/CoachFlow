-- =====================================================
-- CoachFlow - Configuration Supabase
-- =====================================================
-- Tables : users + shared_conversations
-- Permissions : inscription et connexion publiques

-- =====================================================
-- 1. NETTOYAGE
-- =====================================================

DROP TABLE IF EXISTS shared_conversations CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP FUNCTION IF EXISTS handle_new_user() CASCADE;

-- =====================================================
-- 2. TABLE USERS
-- =====================================================

CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  avatar_emoji TEXT DEFAULT '🧑',
  user_context TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour performances
CREATE INDEX idx_users_id ON users(id);
CREATE INDEX idx_users_email ON users(email);

-- =====================================================
-- 3. TABLE SHARED_CONVERSATIONS
-- =====================================================

CREATE TABLE shared_conversations (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  coach_name TEXT NOT NULL,
  coach_avatar TEXT,
  messages JSONB NOT NULL,
  title TEXT,
  shared_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour performances
CREATE INDEX idx_shared_conversations_user_id ON shared_conversations(user_id);
CREATE INDEX idx_shared_conversations_shared_at ON shared_conversations(shared_at DESC);

-- =====================================================
-- 4. ACTIVER ROW LEVEL SECURITY
-- =====================================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE shared_conversations ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 5. POLICIES - TABLE USERS
-- =====================================================

-- Les utilisateurs peuvent voir leur propre profil
CREATE POLICY "Users can view own profile"
  ON users FOR SELECT
  USING (auth.uid() = id);

-- Les utilisateurs peuvent créer leur propre profil
CREATE POLICY "Users can insert own profile"
  ON users FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Les utilisateurs peuvent mettre à jour leur propre profil
CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- =====================================================
-- 6. POLICIES - TABLE SHARED_CONVERSATIONS
-- =====================================================

-- Tout le monde peut lire les conversations partagées
CREATE POLICY "Anyone can read shared conversations"
  ON shared_conversations FOR SELECT
  USING (true);

-- Les utilisateurs peuvent créer leurs propres partages
CREATE POLICY "Users can create own shares"
  ON shared_conversations FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Les utilisateurs peuvent supprimer leurs propres partages
CREATE POLICY "Users can delete own shares"
  ON shared_conversations FOR DELETE
  USING (auth.uid() = user_id);

-- =====================================================
-- 7. TRIGGER AUTO-CRÉATION PROFIL
-- =====================================================

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, name, avatar_emoji)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'avatar_emoji', '🧑')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger pour créer automatiquement un profil à l'inscription
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- =====================================================
-- 8. PERMISSIONS PUBLIQUES
-- =====================================================

GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON users TO anon, authenticated;
GRANT ALL ON shared_conversations TO anon, authenticated;

-- =====================================================
-- FIN DU SCRIPT
-- =====================================================

-- INSTRUCTIONS :
-- 1. Supabase Dashboard → SQL Editor
-- 2. New query → Copier-coller ce script
-- 3. Run → "Success. No rows returned"
-- 
-- TESTER :
-- - Créer un compte dans l'app
-- - Vérifier Table Editor → users (profil auto-créé)
-- - Partager une conversation
-- - Vérifier Table Editor → shared_conversations
