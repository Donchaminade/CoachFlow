-- =====================================================
-- CoachFlow - Script de Configuration Complète (V2)
-- =====================================================
-- Ce script nettoie et recrée toutes les tables necessaires
-- Tables : users, shared_conversations, contacts
-- Permissions : RLS configuré pour Auth, Partage et Réseau
-- =====================================================

-- ⚠️ ATTENTION : CECI SUPPRIME LES DONNÉES EXISTANTES
DROP TABLE IF EXISTS contacts CASCADE;
DROP TABLE IF EXISTS shared_conversations CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP FUNCTION IF EXISTS handle_new_user() CASCADE;

-- =====================================================
-- 1. TABLE USERS
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

-- Index
CREATE INDEX idx_users_id ON users(id);
CREATE INDEX idx_users_email ON users(email);

-- RLS Users
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Lecture : Tout le monde authentifié peut voir les profils (pour la recherche)
CREATE POLICY "Users can view all profiles" 
  ON users FOR SELECT 
  TO authenticated 
  USING (true);

-- Lecture (Self) : Je peux voir mon propre profil (redondant mais explicite)
CREATE POLICY "Users can view own profile" 
  ON users FOR SELECT 
  USING (auth.uid() = id);

-- Modification : Je peux modifier mon profil
CREATE POLICY "Users can update own profile" 
  ON users FOR UPDATE 
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Insertion : Trigger seulement (via le trigger ci-dessous)
-- Mais on garde une policie d'insert au cas où
CREATE POLICY "Users can insert own profile" 
  ON users FOR INSERT 
  WITH CHECK (auth.uid() = id);

-- =====================================================
-- 2. TABLE SHARED_CONVERSATIONS
-- =====================================================

CREATE TABLE shared_conversations (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE, -- Auteur
  recipient_id UUID REFERENCES users(id) ON DELETE SET NULL, -- Destinataire (Optionnel)
  coach_name TEXT NOT NULL,
  coach_avatar TEXT,
  messages JSONB NOT NULL,
  title TEXT,
  shared_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index
CREATE INDEX idx_shared_conversations_user_id ON shared_conversations(user_id);
CREATE INDEX idx_shared_conversations_recipient_id ON shared_conversations(recipient_id);
CREATE INDEX idx_shared_conversations_shared_at ON shared_conversations(shared_at DESC);

-- RLS Shared Conversations
ALTER TABLE shared_conversations ENABLE ROW LEVEL SECURITY;

-- Lecture : Je peux voir si je suis l'auteur OU le destinataire OU si c'est public (logique à affiner si besoin)
-- Ici on dit : public si pas de destinataire ? Ou tout le monde peut lire ?
-- Le code actuel permettait "Anyone can read". 
-- On va dire : Si recipient_id est NULL => Public (Lien partagé). 
-- Si recipient_id est SET => Seul le destinataire et l'auteur peuvent voir.

CREATE POLICY "Access shared conversations"
  ON shared_conversations FOR SELECT
  USING (
    -- C'est à moi
    auth.uid() = user_id 
    OR 
    -- C'est pour moi
    auth.uid() = recipient_id
    OR
    -- C'est public (pas de destinataire spécifique, donc lien web)
    recipient_id IS NULL
  );

-- Création : Je peux créer pour moi
CREATE POLICY "Users can create shares" 
  ON shared_conversations FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- Suppression : Je peux supprimer mes partages
CREATE POLICY "Users can delete own shares" 
  ON shared_conversations FOR DELETE 
  USING (auth.uid() = user_id);

-- =====================================================
-- 3. TABLE CONTACTS
-- =====================================================

CREATE TABLE contacts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE, -- Moi
  contact_id UUID REFERENCES users(id) ON DELETE CASCADE, -- Mon contact
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, contact_id)
);

-- Index
CREATE INDEX idx_contacts_user_id ON contacts(user_id);

-- RLS Contacts
ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;

-- Lecture : Je vois mes contacts
CREATE POLICY "Users can view own contacts" 
  ON contacts FOR SELECT 
  USING (auth.uid() = user_id);

-- Ajout : Je peux ajouter un contact pour moi
CREATE POLICY "Users can add contacts" 
  ON contacts FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- Suppression : Je peux supprimer mes contacts
CREATE POLICY "Users can delete own contacts" 
  ON contacts FOR DELETE 
  USING (auth.uid() = user_id);

-- =====================================================
-- 4. TRIGGER AUTO-PROFIL
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
-- 5. PERMISSIONS
-- =====================================================

GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON users TO anon, authenticated;
GRANT ALL ON shared_conversations TO anon, authenticated;
GRANT ALL ON contacts TO anon, authenticated;

-- Fin
