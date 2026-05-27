# GitHub Finish-Up-A-Thon — CoachFlow V1.1

> Article prêt à publier sur [DEV](https://dev.to). Copiez-collez, ajoutez vos captures/GIF, puis publiez avec les tags `#githubchallenge` `#devchallenge` `#githubcopilot`.

---

## CoachFlow : j'ai enfin fini mon coach IA personnel

### Liens

- **Repository** : https://github.com/Donchaminade/CoachFlow
- **Version soumise** : `v1.1.0` — Direct Share + polish UX
- **Demo** : _(ajoutez un GIF ou une courte vidéo Loom ici)_

---

### Before — Le projet abandonné

En **[DATE]**, j'avais lancé **CoachFlow** pendant un sprint intense : une app Flutter de coaching IA avec personas personnalisés, contexte utilisateur universel, et sync Supabase.

Le MVP fonctionnait (`first commit with v1 working`), mais je suis passé à autre chose. Il restait :

- Partage direct in-app **incomplet** (réseau de contacts sans polish)
- Suppression de messages **non branchée** au repository
- Historique **sans** option « tout effacer »
- Paramètres avec liens GitHub / support **morts**
- Strings hardcodées (`Mon Réseau`) hors i18n

![Before — écran chat / historique](assets/before-placeholder.png)

> Remplacez par une capture du commit `941d27b` ou une ancienne build.

---

### After — Ce qui est fini maintenant (V1.1)

| Fonctionnalité | Statut |
|----------------|--------|
| Chat IA (Bytez / Llama) + contexte utilisateur | ✅ |
| Coaches personnalisés + TTS | ✅ |
| Auth Supabase + biométrie | ✅ |
| Partage par code + **partage direct à un contact** | ✅ |
| Réseau (recherche contacts) | ✅ |
| Suppression message(s) + effacer historique | ✅ |
| i18n FR/EN (réseau, historique) | ✅ |
| Liens GitHub & support dans Paramètres | ✅ |

**Parcours démo recommandé :**
1. Créer un coach → discuter
2. Menu ⋮ message → « Sélectionner » → suppression multiple
3. Icône envoi → partager à un contact du réseau
4. Onglet Conversations partagées → continuer la discussion

![After — partage direct](assets/after-placeholder.png)

---

### Comment GitHub Copilot m'a aidé

Le challenge demande un arc **before/after** *et* l'usage de Copilot. Voici des exemples concrets :

#### 1. Suppression multiple de messages

**Prompt Copilot :**  
« Branche `_deleteSelectedMessages` sur `ChatNotifier.deleteMessages` et rafraîchis `conversationsProvider` après suppression. »

Copilot a généré le flux `deleteMessages` dans le notifier + invalidation Riverpod. J'ai ajouté le mode sélection (AppBar, bordure sur bulles, confirmation dialog).

#### 2. Effacer tout l'historique

**Prompt :**  
« Ajoute `deleteAllMessages` dans `MessageRepository` et un dialog de confirmation dans `HistoryScreen` avec l10n. »

Résultat : une méthode `box.clear()` + invalidation de `historyCoachesProvider` et `conversationsProvider`.

#### 3. Liens externes (Settings)

**Prompt :**  
« Ouvre GitHub et mailto avec url_launcher dans settings_screen. »

Copilot a proposé `launchUrl` + fichier `app_links.dart` centralisé.

#### 4. Localisation « Mon Réseau »

Copilot a complété les getters dans `app_localizations_fr.dart` / `_en.dart` à partir du pattern existant du drawer.

---

### Stack technique

- **Flutter 3** + **Riverpod 2** + **GoRouter**
- **Supabase** (auth, PostgreSQL, RLS, partage cloud)
- **Hive** (offline-first, historique local)
- **Bytez API** (Llama / modèles open source)
- **flutter_tts**, **local_auth**, **flutter_markdown**

Architecture en features (`coach`, `chat`, `sharing`, `network`, `auth`) — clean enough pour évoluer vers un marketplace V2.

---

### Completion arc (timeline)

| Date | Milestone |
|------|-----------|
| _[votre date]_ | `941d27b` — MVP chat local |
| _[...]_ | Supabase, biométrie, audio |
| _[...]_ | Partage conversations + continuation |
| **Mai–Juin 2026** | **Finish-Up-A-Thon** — V1.1 Direct Share polish, TODOs critiques, article DEV |

---

### Ce qui reste (hors scope V1.1)

- **Voice Mode** duplex (V1.2)
- **Coach Marketplace** (V2.0)
- Compteur de messages non lus

---

### Conclusion

CoachFlow n'était pas un échec — c'était un projet **à 80 %** qui attendait une dernière passe. Le Finish-Up-A-Thon m'a forcé à fermer la boucle : partage social, gestion de l'historique, et polish UX.

Si vous voulez tester : clonez le repo, copiez `.env.example` → `.env`, configurez Supabase, `flutter run`.

Merci à **GitHub** et **DEV** pour ce challenge — et à **Copilot** pour m'avoir fait gagner des heures sur le boilerplate.

---

`#githubchallenge` `#devchallenge` `#githubcopilot` `#flutter` `#ai`
