# TravAI Pro — installatiehandleiding

Eenmalige installatie, duurt ± 15 minuten. Daarna werkt alles vanzelf.

## Stap 1 — Maak een gratis Supabase-account

1. Ga naar **https://supabase.com** en klik op *Start your project*.
2. Meld je aan (kan met GitHub of e-mail).
3. Klik op **New project**, kies een naam (bv. `travai`), kies een sterk databasewachtwoord (bewaar het ergens, je hebt het zelden nodig) en als regio **West EU**.
4. Wacht 1-2 minuten tot het project klaar is.

## Stap 2 — Zet de database op

1. Klik links in het menu op **SQL Editor**.
2. Open het bestand `supabase-setup.sql` (zit in deze map), kopieer de volledige inhoud en plak die in de editor.
3. Klik op **Run**. Je zou "Success" moeten zien.

## Stap 3 — Instellingen voor aanmelden

1. Ga links naar **Authentication → Sign In / Providers**.
2. Controleer dat **Email** aan staat.
3. Optioneel maar handig: zet **Confirm email** *uit* — dan kunnen jij en je genodigden meteen inloggen zonder bevestigingsmail. (Laat je het aan, dan moet elke nieuwe gebruiker eerst op de link in zijn mailbox klikken.)

## Stap 4 — Sleutels kopiëren

1. Ga links naar **Project Settings** (tandwiel) **→ API** (of "API Keys").
2. Kopieer twee dingen:
   - **Project URL** (ziet eruit als `https://xxxxx.supabase.co`)
   - **anon / public key** (lange tekenreeks die begint met `eyJ…`)
3. Open de app (`index.html`), plak beide in het instelscherm en klik **Verbinden**. Dit hoef je maar één keer per toestel te doen.

## Stap 5 — Zet de app online (zodat anderen erbij kunnen)

De makkelijkste gratis optie is **Netlify Drop**:

1. Ga naar **https://app.netlify.com/drop** (gratis account nodig).
2. Sleep de map `TravAI-Pro` (of enkel `index.html`) naar de pagina.
3. Je krijgt meteen een webadres zoals `https://jouwnaam.netlify.app`. Dat adres deel je met je reisgenoten.
4. Tip: via *Site settings → Change site name* kies je een mooiere naam.

Alternatieven: GitHub Pages of Vercel werken ook prima.

## Stap 6 — Op je iPhone zetten

1. Open het webadres in **Safari** op je iPhone.
2. Log in, tik dan op de **Deel-knop → "Zet op beginscherm"**.
3. De app staat nu als icoon tussen je andere apps, op volledig scherm.

## Hoe deel je een reis?

1. Open de reis → tabblad **Info** → vak **Delen**.
2. Vul het e-mailadres van je reisgenoot in en tik **Uitnodigen**.
3. Die persoon maakt (op hetzelfde webadres) een account aan met dat e-mailadres — de reis verschijnt automatisch, **alleen-lezen**.
4. Toegang intrekken kan op dezelfde plek met het ✕-knopje.

## Goed om te weten

- Alles staat veilig in jouw eigen Supabase-database; alleen jij en je genodigden kunnen erbij (afgedwongen op databaseniveau, niet enkel in de app).
- Gratis limieten van Supabase (500 MB database, 50.000 gebruikers) zijn ruim voldoende voor persoonlijk gebruik.
- Internet is nodig; het is een cloud-app.
- Back-up maken: Info-tabblad → *Exporteer alle reizen (JSON)*.
