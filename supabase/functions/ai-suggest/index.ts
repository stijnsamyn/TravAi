// TravAI — AI-reisagent: stelt per bestemming activiteiten voor, verdeeld over de verblijfsdagen.
// De Anthropic API-key staat als Supabase-secret (ANTHROPIC_API_KEY) en komt nooit in de app terecht.
import Anthropic from "npm:@anthropic-ai/sdk";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  try {
    const apiKey = Deno.env.get("ANTHROPIC_API_KEY");
    if (!apiKey) {
      return json({ error: "AI is nog niet geactiveerd: de Anthropic API-key ontbreekt op de server." }, 500);
    }
    const { dest, region, days, existing } = await req.json();
    if (!dest || !Array.isArray(days) || days.length === 0 || days.length > 21) {
      return json({ error: "dest en days (1-21 datums) zijn vereist" }, 400);
    }

    const schema = {
      type: "object",
      additionalProperties: false,
      required: ["suggestions"],
      properties: {
        suggestions: {
          type: "array",
          items: {
            type: "object",
            additionalProperties: false,
            required: ["title", "type", "day", "time", "duration_min", "note", "search_query"],
            properties: {
              title: { type: "string" },
              type: { type: "string", enum: ["sight", "museum", "castle", "nature", "sport", "shop", "food", "act"] },
              day: { type: "string", enum: days },
              time: { type: "string" },
              duration_min: { type: "integer" },
              note: { type: "string" },
              search_query: { type: "string" },
            },
          },
        },
      },
    };

    const prompt =
      `Je bent een ervaren reisagent. Stel activiteiten voor in en rond ${dest}${region ? ` (${region})` : ""}.\n` +
      `Verblijf: ${days.length} dag(en), datums: ${days.join(", ")}.\n` +
      `Al gepland (stel deze NIET opnieuw voor): ${(existing || []).join("; ") || "nog niets"}.\n\n` +
      `Regels:\n` +
      `- 2 à 3 voorstellen per dag, verdeeld over alle datums; totaal maximaal ${Math.min(days.length * 3, 15)}.\n` +
      `- Mix van hoogtepunten en lokale pareltjes; varieer de types (bezienswaardigheid, museum, natuur, eten...).\n` +
      `- Realistische tijden tussen 09:00 en 20:00 ("time" = startuur "HH:MM", "duration_min" = duur in minuten); hou rekening met reistijd ertussen.\n` +
      `- "note": één korte zin in het Nederlands waarom dit de moeite is.\n` +
      `- "search_query": de officiële naam + plaats, geschikt om de plek in Google Maps te vinden.\n` +
      `- Alleen plekken die echt bestaan.`;

    const client = new Anthropic({ apiKey });
    const model = Deno.env.get("AI_MODEL") || "claude-opus-4-8";
    const resp = await client.messages.create({
      model,
      max_tokens: 4000,
      thinking: { type: "adaptive" },
      output_config: { format: { type: "json_schema", schema } },
      messages: [{ role: "user", content: prompt }],
    });

    if (resp.stop_reason === "refusal") {
      return json({ error: "De AI kon voor deze aanvraag geen voorstellen doen." }, 502);
    }
    const text = resp.content.find((b: { type: string }) => b.type === "text");
    if (!text) return json({ error: "Leeg antwoord van het model." }, 502);
    return json(JSON.parse((text as { text: string }).text));
  } catch (e) {
    return json({ error: String((e as Error)?.message ?? e) }, 500);
  }
});
