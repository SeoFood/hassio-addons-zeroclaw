# ZeroClaw Add-on Test Playbook (Home Assistant)

## Ziel

Sicherstellen, dass das Add-on `zeroclaw` auf `amd64` und `aarch64` korrekt installiert, startet und über Ingress erreichbar ist.

## Voraussetzungen

- Home Assistant OS mit Supervisor
- Zugriff auf den Add-on Store
- Dieses Repository als Add-on-Quelle eingebunden
- Gültiger LLM API-Key (z. B. OpenRouter, OpenAI, Anthropic)

## 1. Repository einbinden

1. Add-on Store öffnen.
2. Menü oben rechts -> Repositories.
3. Repository URL eintragen: `https://github.com/SeoFood/hassio-addons-zeroclaw`.
4. Speichern und Store neu laden.

## 2. Installation

1. Add-on `ZeroClaw` auswählen.
2. Installieren.
3. Nicht direkt starten, erst Konfiguration setzen.

## 3. Basis-Konfiguration

Setze folgende Optionen im Add-on:

```yaml
provider: openrouter
api_key: "<DEIN_API_KEY>"
model: ""
require_pairing: false
allow_public_bind: true
gateway_host: 0.0.0.0
```

Hinweis: `api_key` ist Pflicht. Ohne Key beendet sich das Add-on absichtlich mit Fehler.

## 4. Start & Health

1. Add-on starten.
2. Logs prüfen. Erwartet:
   - `ZeroClaw Gateway`
   - `Provider: <dein_provider>`
   - Kein sofortiger Exit
3. Ingress öffnen.
4. Watchdog prüfen (`/health`): Status darf nicht fehlschlagen.

## 5. Funktionaler Test

1. Ingress öffnen.
2. Eine einfache Anfrage schicken (z. B. `Hello`).
3. Erwartung:
   - HTTP-Antwort vom Gateway
   - Keine Auth-/Provider-Fehler im Log

## 6. Persistenz-Test

1. Add-on stoppen.
2. Home Assistant neu starten.
3. Add-on wieder starten.
4. Erwartung:
   - Start weiterhin erfolgreich
   - Zustand unter `/data/zeroclaw` bleibt erhalten

## 7. Negativtests

- `api_key` leer -> Add-on muss mit klarer Fehlermeldung stoppen.
- Ungültiger `provider` -> Start möglich, aber Provider-Fehler bei Request sichtbar.
- `allow_public_bind: false` + `gateway_host: 0.0.0.0` -> erwarteter Bind-Fehler von ZeroClaw.

## 8. Architektur-Matrix

Führe mindestens je einmal aus auf:

- `amd64` (z. B. HA auf x86 Mini-PC/VM)
- `aarch64` (z. B. Raspberry Pi 4/5 64-bit)

## 9. Abnahme-Kriterien

- Installation erfolgreich
- Start erfolgreich
- Ingress erreichbar
- `/health` stabil
- Anfrage wird verarbeitet
- Persistenz funktioniert
