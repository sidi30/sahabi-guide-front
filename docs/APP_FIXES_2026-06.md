# Correctifs app Sahabi Guide — 2026-06

5 problèmes signalés après tests. État : **code terminé + testé** ; restent 2
actions **infra/clés** (côté serveur) que seul le propriétaire peut faire.

| # | Problème | Statut code | Reste à faire (infra) |
|---|----------|-------------|------------------------|
| 1 | Pas de son (douas / réponses IA) | ✅ Fait | — |
| 2 | Vidéos « not found » | ✅ Fait | (option) re-seed prod |
| 3 | Rituels : mêmes conseils partout | ✅ Fait + testé | — |
| 4 | IA limitée (Sunna, histoire) | ✅ Fait + testé | **clé Cohere valide** |
| 5 | Voix haoussa / wolof… | ✅ Front + proxy | **déployer microservice voix (GPU)** |

---

## 1. Audio des douas + réponses IA — `flutter_tts` (synthèse vocale)
**Cause :** tous les douas/rituels pointaient vers `assets/audio/*.mp3` **absents
du bundle** (dossier désactivé dans `pubspec.yaml`) → chaque lecture échouait en
silence.
**Fix :** nouveau `core/services/tts_service.dart` (TTS on-device fr/ar/en +
backend voix pour langues africaines). `DuaPlayer` lit désormais le texte de la
doua (arabe / traduction) par synthèse quand il n'y a pas de fichier audio réel
(http). Les réponses de l'assistant étaient déjà lues via `VoiceService.speak`.

## 2. Vidéos
**Cause :** côté rituel, `videoPath` pointait vers des `.mp4` inexistants ; côté
**page Vidéos**, dépendance au backend `/api/v1/videos/active` (vide/injoignable
→ « Aucune vidéo »). Le backend a pourtant 8 vidéos HAJJ seedées.
**Fix :** la page Vidéos retombe sur une **liste locale curatée** (YouTube) si le
backend renvoie vide. Les vidéos de rituels (`rituals_seed.json`) ont déjà des
URLs YouTube/recherche valides.

## 3. Rituels — conseils propres à chaque rite (3 critères + comment faire)
**Cause :** `ritual_detail_section.dart` codait les conseils en dur via
`switch(ritual.name)` avec **3 cas seulement** → tous les autres rites tombaient
sur le texte générique.
**Fix :** `features/rituals/data/ritual_guidance.dart` = guide PROPRE aux **13
rites** sur 4 axes : **Étapes importantes**, **Comment l'accomplir** (variantes),
**Sécurité**, **Conseils pratiques**. Rendu data-driven + lecture vocale.
Vérifié par `test/ritual_guidance_test.dart` (16 tests, mapping + non-duplication).

## 4. IA — comprendre la Sunna + l'histoire de l'Islam
**Cause :** prompt système bridé (réponse **3 phrases / 350 car. max**), périmètre
centré Hajj.
**Fix (`HajjChatService.java`, `TopicGuard.java`) :**
- Cap relevé à **8 phrases / 1200 caractères** (réponses pédagogiques).
- Périmètre élargi : Sunna complète, sîra, **histoire de l'Islam** (califes,
  dynasties, grandes batailles, savants), mots-clés ajoutés à l'allowlist.
- Tests backend mis à jour → **24/24 verts**.
- ⚠️ **Action requise** : sur le VPS, la clé `COHERE_API_KEY` est de forme `hf_…`
  (token HuggingFace) → **invalide pour Cohere** → RAG + LLM Cohere muets. Mettre
  une vraie clé Cohere (et/ou `GEMINI_API_KEY`) pour sortir du fallback statique.
  Voir mémoire `ai-prod-activation`.

## 5. Voix en haoussa / wolof / zarma / yoruba / swahili / bambara
**Architecture (déjà en place) :** TTS on-device pour fr/ar/en ; pour les langues
africaines, l'app appelle le microservice **SeamlessM4T v2** (`sahabi-guide-voice`)
via le proxy `/api/v1/assistant/voice/*`. Sans backend, dégradation propre
(repli voix arabe / message), jamais de plantage.
**Fix code :** le proxy `VoiceClient` **normalise automatiquement** la base-url
vers `/v1` (le service FastAPI sert sous `/v1/...`) → plus de 404 silencieux si
on oublie le suffixe.
**⚠️ Action requise (infra)** pour activer réellement la voix africaine :
1. Déployer `sahabi-guide-voice` (modèle ~9 Go, **GPU recommandé**) — fichier
   `deploy/docker-compose.gpu.yml`, **pas** le compose CPU du VPS actuel.
2. Sur l'API : `VOICE_ENABLED=true` et `VOICE_BASE_URL=http://<hôte-gpu>:8001`
   (le `/v1` est ajouté automatiquement désormais).

> Note : `dje` (Zarma) est rendu par la voix haoussa côté SeamlessM4T (pas de
> voix Zarma native dans le modèle).

---

### Déploiement
- **App mobile** : rebuild requis (changement Dart + nouveau service). iOS via
  `gh workflow run ios-testflight.yml`, Android via `android-play.yml`. Penser à
  bumper `pubspec.yaml`.
- **Backend API** : redeploy `sahabi-guide-api` (tar-over-ssh habituel) pour
  prendre le nouveau prompt + le proxy voix.
