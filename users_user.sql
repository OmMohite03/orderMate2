SELECT email, password FROM public.users_users where is_active = true and email is not null
ORDER BY id desc 