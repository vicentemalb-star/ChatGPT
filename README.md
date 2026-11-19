# Mi Norte V28 · fuente de despliegue

Candidata V28 adaptada para Pages Functions y Supabase. No incluye respaldos financieros ni claves privadas.

## Cloudflare Pages

- Root directory: `/`
- Build command: vacío
- Build output directory: raíz del repositorio (campo vacío)
- Variables necesarias: `SUPABASE_URL` y `SUPABASE_ANON_KEY` en Cloudflare, configuradas como secretos/variables del entorno.
- La clave debe ser pública anon/publishable; nunca usar `service_role`.

## Supabase

El SQL de `sql/mi_norte_v28_prod.sql` crea tablas separadas con prefijo `mi_norte_v28_prod_`. Revisarlo antes de ejecutarlo. No se ha ejecutado.

## Estado

Código preparado. No conectar este repositorio al proyecto de producción `mi-norte-finanzas` hasta terminar la prueba de migración, recuperación y reversión.