
  create table "public"."unions" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null
      );


alter table "public"."messages" add column "union_id" uuid not null;

CREATE UNIQUE INDEX unions_pkey ON public.unions USING btree (id);

alter table "public"."unions" add constraint "unions_pkey" PRIMARY KEY using index "unions_pkey";

alter table "public"."messages" add constraint "messages_union_id_fkey" FOREIGN KEY (union_id) REFERENCES public.unions(id) ON DELETE CASCADE not valid;

alter table "public"."messages" validate constraint "messages_union_id_fkey";

grant delete on table "public"."unions" to "anon";

grant insert on table "public"."unions" to "anon";

grant references on table "public"."unions" to "anon";

grant select on table "public"."unions" to "anon";

grant trigger on table "public"."unions" to "anon";

grant truncate on table "public"."unions" to "anon";

grant update on table "public"."unions" to "anon";

grant delete on table "public"."unions" to "authenticated";

grant insert on table "public"."unions" to "authenticated";

grant references on table "public"."unions" to "authenticated";

grant select on table "public"."unions" to "authenticated";

grant trigger on table "public"."unions" to "authenticated";

grant truncate on table "public"."unions" to "authenticated";

grant update on table "public"."unions" to "authenticated";

grant delete on table "public"."unions" to "service_role";

grant insert on table "public"."unions" to "service_role";

grant references on table "public"."unions" to "service_role";

grant select on table "public"."unions" to "service_role";

grant trigger on table "public"."unions" to "service_role";

grant truncate on table "public"."unions" to "service_role";

grant update on table "public"."unions" to "service_role";


