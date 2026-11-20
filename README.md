# Mi Norte V28 · QA aislada

Rama para desplegar únicamente en el proyecto Cloudflare Pages `mi-norte-v28-qa`. No conectar esta rama a `mi-norte-finanzas`.

## Configuración de Cloudflare (QA)
- Framework: None.
- Build command: vacío.
- Build output directory: raíz del repositorio.
- Variables del entorno QA: `SUPABASE_URL` y `SUPABASE_ANON_KEY`; deben apuntar al proyecto Supabase de QA. No usar `service_role`.

## Supabase (solo QA)
`sql/mi_norte_v28_qa.sql` crea tablas V28 con prefijo `mi_norte_v28_qa_` y limita RPC a los participantes QA ya registrados en `mi_norte_qa_participants`. Revisar y ejecutar solo en el proyecto Supabase de QA.

Esta rama no incluye respaldos ni estados financieros precargados. Usar datos sintéticos; no importar respaldo productivo aquí.
