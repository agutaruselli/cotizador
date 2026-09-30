import { createClient } from '@supabase/supabase-js';
import { parseEnv } from './env';

const env = parseEnv(import.meta.env);

// Solo la clave pública anon: la service_role nunca llega al navegador.
export const supabase = createClient(env.VITE_SUPABASE_URL, env.VITE_SUPABASE_ANON_KEY);
