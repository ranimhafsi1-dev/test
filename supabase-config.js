/* Configuration publique Supabase pour Affaryette.
   Le Publishable key peut être utilisé dans le navigateur avec RLS activé.
   Ne jamais ajouter une Secret key / service_role ici. */
const SUPABASE_URL = 'https://tkzotamlynzsfjhrbxem.supabase.co';
const SUPABASE_PUBLISHABLE_KEY = 'sb_publishable_eRB_SNUzTz0diKBaKv0h-g_FlNwRVy7';
const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY);
