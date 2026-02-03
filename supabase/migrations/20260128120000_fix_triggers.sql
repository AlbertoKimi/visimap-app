-- Update the handle_new_user function to correctly map the new metadata fields
-- Run this in your Supabase SQL Editor

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, email, nombre, primer_apellido, segundo_apellido)
  VALUES (
    new.id,
    new.email,
    new.raw_user_meta_data ->> 'nombre',
    new.raw_user_meta_data ->> 'apellido1',
    new.raw_user_meta_data ->> 'apellido2'
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
