-- Comprehensive fix for the handle_new_user trigger
-- This script:
-- 1. Updates the trigger to map all fields correctly (including role_id).
-- 2. Handles type casting for role_id.
-- 3. Ensures usage of COALESCE for optional fields.

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (
    id, 
    email, 
    nombre, 
    primer_apellido, 
    segundo_apellido, 
    telefono,
    role_id
  )
  VALUES (
    new.id,
    new.email,
    new.raw_user_meta_data ->> 'nombre',
    new.raw_user_meta_data ->> 'apellido1',
    new.raw_user_meta_data ->> 'apellido2',
    new.raw_user_meta_data ->> 'telefono',
    COALESCE((new.raw_user_meta_data ->> 'role_id')::bigint, 2) -- Default to 2 (Trabajador) if missing or null
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
