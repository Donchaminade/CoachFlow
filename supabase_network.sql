-- =====================================================
-- CoachFlow - Module Réseau & Contacts
-- =====================================================

-- 1. Table Contacts
CREATE TABLE IF NOT EXISTS contacts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE, -- Moi
  contact_id UUID REFERENCES users(id) ON DELETE CASCADE, -- Mon ami
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, contact_id)
);

-- Index pour performances
CREATE INDEX IF NOT EXISTS idx_contacts_user_id ON contacts(user_id);
CREATE INDEX IF NOT EXISTS idx_contacts_contact_id ON contacts(contact_id);

-- 2. RLS permissions - Table Contacts
ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;

-- Je peux voir mes contacts
CREATE POLICY "Users can view own contacts" 
  ON contacts FOR SELECT 
  USING (auth.uid() = user_id);

-- Je peux ajouter un contact (si je suis authentifié)
CREATE POLICY "Users can add contacts" 
  ON contacts FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- Je peux supprimer un contact
CREATE POLICY "Users can delete own contacts" 
  ON contacts FOR DELETE 
  USING (auth.uid() = user_id);

-- 3. Update Users Policy (Search)
-- Allow authenticated users to view basic info of other users for search
CREATE POLICY "Users can view all profiles for search" 
  ON users FOR SELECT 
  TO authenticated 
  USING (true);

-- =====================================================
-- 4. MISE À JOUR SHARED_CONVERSATIONS (Direct Share)
-- =====================================================

-- Ajout de la colonne recipient_id pour le partage direct
ALTER TABLE shared_conversations 
ADD COLUMN IF NOT EXISTS recipient_id UUID REFERENCES users(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_shared_conversations_recipient_id ON shared_conversations(recipient_id);

-- Policy pour que le destinataire puisse voir la conversation
CREATE POLICY "Recipients can view shared conversations"
  ON shared_conversations FOR SELECT
  USING (auth.uid() = recipient_id);

-- =====================================================
-- FIN DU SCRIPT
-- =====================================================
