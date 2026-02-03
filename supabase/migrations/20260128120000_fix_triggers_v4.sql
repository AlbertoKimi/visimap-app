-- Fix for the handle_new_user trigger (V4)
-- This version looks up the role_id dynamically based on the role name (e.g., 'admin', 'trabajador')
-- This prevents errors if the Role IDs are not 1 and 2.

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
DECLARE
  assigned_role_id bigint;
  role_name__ text;
BEGIN
  -- Get the role name from metadata (default to 'trabajador' if missing)
  role_name__ := COALESCE(new.raw_user_meta_data ->> 'rol', 'trabajador');

  -- Find the corresponding ID in the roles table (case-insensitive search)
  SELECT id INTO assigned_role_id
  FROM public.roles
  WHERE nombre ILIKE role_name__
  LIMIT 1;

  -- Fallback: If no role found, try to use the hardcoded role_id or default to a safe value (if valid)
  IF assigned_role_id IS NULL THEN
      assigned_role_id := COALESCE((new.raw_user_meta_data ->> 'role_id')::bigint, 2);
  END IF;

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
    assigned_role_id
  );
  
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
