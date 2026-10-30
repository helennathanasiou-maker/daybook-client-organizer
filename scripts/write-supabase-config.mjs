import { writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";

const supabaseUrl = process.env.DAYBOOK_SUPABASE_URL;
const anonKey = process.env.DAYBOOK_SUPABASE_ANON_KEY;

if (!supabaseUrl || !anonKey) {
  throw new Error("Set DAYBOOK_SUPABASE_URL and DAYBOOK_SUPABASE_ANON_KEY in Netlify environment variables.");
}

const parsedUrl = new URL(supabaseUrl);
if (parsedUrl.protocol !== "https:") {
  throw new Error("DAYBOOK_SUPABASE_URL must use HTTPS.");
}

const newline = String.fromCharCode(10);
const config = [
  "window.DAYBOOK_SUPABASE = Object.freeze({",
  "  url: " + JSON.stringify(supabaseUrl) + ",",
  "  anonKey: " + JSON.stringify(anonKey) + ",",
  "  requireCloudAuth: true",
  "});",
  ""
].join(newline);
const configPath = fileURLToPath(new URL("../supabase-config.js", import.meta.url));

writeFileSync(configPath, config, "utf8");
