-- Añade la columna telefono a la tabla public.usuario
ALTER TABLE public.usuario
ADD COLUMN telefono VARCHAR(20) NULL;