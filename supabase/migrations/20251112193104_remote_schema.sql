


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."tipo_evento" AS ENUM (
    'actividad_publica',
    'evento_privado',
    'mantenimiento',
    'otro'
);


ALTER TYPE "public"."tipo_evento" OWNER TO "postgres";


CREATE TYPE "public"."tipo_rol" AS ENUM (
    'administrador',
    'trabajador'
);


ALTER TYPE "public"."tipo_rol" OWNER TO "postgres";


CREATE TYPE "public"."tipo_visita" AS ENUM (
    'individual',
    'grupo',
    'escolar',
    'otro'
);


ALTER TYPE "public"."tipo_visita" OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."configuracion" (
    "id_config" bigint NOT NULL,
    "nombre_clave" character varying(50) NOT NULL,
    "valor" "text" NOT NULL,
    "actualizado_por" "uuid" NOT NULL,
    "ultima_actualizacion" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."configuracion" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."evento" (
    "id_evento" bigint NOT NULL,
    "id_usuario" "uuid" NOT NULL,
    "tipo" "public"."tipo_evento" NOT NULL,
    "nombre_evento" character varying(100) NOT NULL,
    "descripcion" "text",
    "fecha_inicio" timestamp with time zone NOT NULL,
    "fecha_fin" timestamp with time zone NOT NULL,
    CONSTRAINT "chk_fecha_orden" CHECK (("fecha_fin" >= "fecha_inicio"))
);


ALTER TABLE "public"."evento" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."evento_id_evento_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."evento_id_evento_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."evento_id_evento_seq" OWNED BY "public"."evento"."id_evento";



CREATE TABLE IF NOT EXISTS "public"."pais" (
    "id_pais" smallint NOT NULL,
    "nombre_pais" character varying(100) NOT NULL,
    "codigo_iso" character(3) NOT NULL
);


ALTER TABLE "public"."pais" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."provincia" (
    "id_provincia" smallint NOT NULL,
    "nombre_provincia" character varying(50) NOT NULL,
    "codigo_iso" character(2) NOT NULL,
    "coordenadas_centro" "point" NOT NULL
);


ALTER TABLE "public"."provincia" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."registro_visitante" (
    "id_registro" bigint NOT NULL,
    "id_pais" smallint NOT NULL,
    "id_provincia" smallint,
    "id_usuario" "uuid" NOT NULL,
    "cantidad" integer NOT NULL,
    "tipo_visita" "public"."tipo_visita" NOT NULL,
    "creado_en" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "chk_cantidad_positiva" CHECK (("cantidad" >= 0))
);


ALTER TABLE "public"."registro_visitante" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."registro_visitante_id_registro_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."registro_visitante_id_registro_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."registro_visitante_id_registro_seq" OWNED BY "public"."registro_visitante"."id_registro";



CREATE TABLE IF NOT EXISTS "public"."usuario" (
    "id_usuario" "uuid" NOT NULL,
    "nombre" character varying(25) NOT NULL,
    "apellido1" character varying(25) NOT NULL,
    "apellido2" character varying(25),
    "rol" "public"."tipo_rol" DEFAULT 'trabajador'::"public"."tipo_rol" NOT NULL,
    "email" character varying(60) NOT NULL
);


ALTER TABLE "public"."usuario" OWNER TO "postgres";


ALTER TABLE ONLY "public"."evento" ALTER COLUMN "id_evento" SET DEFAULT "nextval"('"public"."evento_id_evento_seq"'::"regclass");



ALTER TABLE ONLY "public"."registro_visitante" ALTER COLUMN "id_registro" SET DEFAULT "nextval"('"public"."registro_visitante_id_registro_seq"'::"regclass");



ALTER TABLE ONLY "public"."configuracion"
    ADD CONSTRAINT "configuracion_nombre_clave_key" UNIQUE ("nombre_clave");



ALTER TABLE ONLY "public"."configuracion"
    ADD CONSTRAINT "configuracion_pkey" PRIMARY KEY ("id_config");



ALTER TABLE ONLY "public"."evento"
    ADD CONSTRAINT "evento_pkey" PRIMARY KEY ("id_evento");



ALTER TABLE ONLY "public"."pais"
    ADD CONSTRAINT "pais_codigo_iso_key" UNIQUE ("codigo_iso");



ALTER TABLE ONLY "public"."pais"
    ADD CONSTRAINT "pais_nombre_pais_key" UNIQUE ("nombre_pais");



ALTER TABLE ONLY "public"."pais"
    ADD CONSTRAINT "pais_pkey" PRIMARY KEY ("id_pais");



ALTER TABLE ONLY "public"."provincia"
    ADD CONSTRAINT "provincia_codigo_iso_key" UNIQUE ("codigo_iso");



ALTER TABLE ONLY "public"."provincia"
    ADD CONSTRAINT "provincia_nombre_provincia_key" UNIQUE ("nombre_provincia");



ALTER TABLE ONLY "public"."provincia"
    ADD CONSTRAINT "provincia_pkey" PRIMARY KEY ("id_provincia");



ALTER TABLE ONLY "public"."registro_visitante"
    ADD CONSTRAINT "registro_visitante_pkey" PRIMARY KEY ("id_registro");



ALTER TABLE ONLY "public"."usuario"
    ADD CONSTRAINT "usuario_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."usuario"
    ADD CONSTRAINT "usuario_pkey" PRIMARY KEY ("id_usuario");



ALTER TABLE ONLY "public"."configuracion"
    ADD CONSTRAINT "configuracion_actualizado_por_fkey" FOREIGN KEY ("actualizado_por") REFERENCES "public"."usuario"("id_usuario");



ALTER TABLE ONLY "public"."evento"
    ADD CONSTRAINT "evento_id_usuario_fkey" FOREIGN KEY ("id_usuario") REFERENCES "public"."usuario"("id_usuario");



ALTER TABLE ONLY "public"."registro_visitante"
    ADD CONSTRAINT "registro_visitante_id_pais_fkey" FOREIGN KEY ("id_pais") REFERENCES "public"."pais"("id_pais");



ALTER TABLE ONLY "public"."registro_visitante"
    ADD CONSTRAINT "registro_visitante_id_provincia_fkey" FOREIGN KEY ("id_provincia") REFERENCES "public"."provincia"("id_provincia");



ALTER TABLE ONLY "public"."registro_visitante"
    ADD CONSTRAINT "registro_visitante_id_usuario_fkey" FOREIGN KEY ("id_usuario") REFERENCES "public"."usuario"("id_usuario");



ALTER TABLE ONLY "public"."usuario"
    ADD CONSTRAINT "usuario_id_usuario_fkey" FOREIGN KEY ("id_usuario") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



CREATE POLICY "Administradores pueden gestionar configuracion" ON "public"."configuracion" USING ((( SELECT "usuario"."rol"
   FROM "public"."usuario"
  WHERE ("usuario"."id_usuario" = "auth"."uid"())) = 'administrador'::"public"."tipo_rol"));



CREATE POLICY "Admins pueden gestionar eventos" ON "public"."evento" USING ((( SELECT "usuario"."rol"
   FROM "public"."usuario"
  WHERE ("usuario"."id_usuario" = "auth"."uid"())) = 'administrador'::"public"."tipo_rol"));



CREATE POLICY "Admins pueden gestionar paises" ON "public"."pais" USING ((( SELECT "usuario"."rol"
   FROM "public"."usuario"
  WHERE ("usuario"."id_usuario" = "auth"."uid"())) = 'administrador'::"public"."tipo_rol"));



CREATE POLICY "Permitir insertar a usuarios autenticados" ON "public"."registro_visitante" FOR INSERT TO "authenticated" WITH CHECK (true);



CREATE POLICY "Permitir leer provincias a todos" ON "public"."provincia" FOR SELECT USING (true);



CREATE POLICY "Usuarios autenticados pueden leer paises" ON "public"."pais" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Usuarios autenticados pueden ver eventos" ON "public"."evento" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Usuarios pueden ver su propio perfil" ON "public"."usuario" FOR SELECT USING (("auth"."uid"() = "id_usuario"));



ALTER TABLE "public"."configuracion" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."evento" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."pais" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."provincia" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."registro_visitante" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."usuario" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";








































































































































































GRANT ALL ON TABLE "public"."configuracion" TO "anon";
GRANT ALL ON TABLE "public"."configuracion" TO "authenticated";
GRANT ALL ON TABLE "public"."configuracion" TO "service_role";



GRANT ALL ON TABLE "public"."evento" TO "anon";
GRANT ALL ON TABLE "public"."evento" TO "authenticated";
GRANT ALL ON TABLE "public"."evento" TO "service_role";



GRANT ALL ON SEQUENCE "public"."evento_id_evento_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."evento_id_evento_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."evento_id_evento_seq" TO "service_role";



GRANT ALL ON TABLE "public"."pais" TO "anon";
GRANT ALL ON TABLE "public"."pais" TO "authenticated";
GRANT ALL ON TABLE "public"."pais" TO "service_role";



GRANT ALL ON TABLE "public"."provincia" TO "anon";
GRANT ALL ON TABLE "public"."provincia" TO "authenticated";
GRANT ALL ON TABLE "public"."provincia" TO "service_role";



GRANT ALL ON TABLE "public"."registro_visitante" TO "anon";
GRANT ALL ON TABLE "public"."registro_visitante" TO "authenticated";
GRANT ALL ON TABLE "public"."registro_visitante" TO "service_role";



GRANT ALL ON SEQUENCE "public"."registro_visitante_id_registro_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."registro_visitante_id_registro_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."registro_visitante_id_registro_seq" TO "service_role";



GRANT ALL ON TABLE "public"."usuario" TO "anon";
GRANT ALL ON TABLE "public"."usuario" TO "authenticated";
GRANT ALL ON TABLE "public"."usuario" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";































drop extension if exists "pg_net";


