export async function onRequestGet({env}) {
  const url = env.SUPABASE_URL || "";
  const anonKey = env.SUPABASE_ANON_KEY || "";
  if (!url || !anonKey) return Response.json({error:"Supabase aún no está configurado."},{status:503,headers:{"Cache-Control":"no-store"}});
  return Response.json({url,anonKey},{headers:{"Cache-Control":"no-store"}});
}
