Initialising login role...
Dumping schemas from remote database...


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


CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "pg_database_owner";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE OR REPLACE FUNCTION "public"."before_user_created_hook"("event" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$BEGIN
  -- Add custom metadata to user
  event := jsonb_set(event, '{user_metadata,source}', '"theholetruth.org"');
  event := jsonb_set(event, '{user_metadata,created_via}', '"web_app"');
  
  -- Add timestamp
  event := jsonb_set(event, '{user_metadata,created_at}', to_jsonb(now()));
  
  RETURN event;
END;$$;


ALTER FUNCTION "public"."before_user_created_hook"("event" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."custom_access_token_hook"("event" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  user_id uuid;
  user_email text;
  user_role text;
BEGIN
  -- Extract user information
  user_id := (event->>'user_id')::uuid;
  user_email := event->>'email';
  
  -- Determine user role based on email domain
  IF user_email LIKE '%@theholetruth.org' THEN
    user_role := 'admin';
  ELSE
    user_role := 'user';
  END IF;
  
  -- Add custom claims to JWT
  event := jsonb_set(event, '{claims,role}', to_jsonb(user_role));
  event := jsonb_set(event, '{claims,app_metadata,role}', to_jsonb(user_role));
  event := jsonb_set(event, '{claims,app_metadata,source}', '"theholetruth.org"');
  
  RETURN event;
END;
$$;


ALTER FUNCTION "public"."custom_access_token_hook"("event" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."increment_template_usage"("template_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  UPDATE foia_templates 
  SET usage_count = usage_count + 1,
      updated_at = NOW()
  WHERE id = template_id;
END;
$$;


ALTER FUNCTION "public"."increment_template_usage"("template_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."send_email_hook"("event" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$DECLARE
  email_type text;
  user_email text;
  user_name text;
  custom_html text;
BEGIN
  email_type := event->>'type';
  user_email := event->>'email';
  user_name := COALESCE(event->'user_metadata'->>'full_name', 'User');
  
  -- Customize email content based on type
  CASE email_type
    WHEN 'signup' THEN
      custom_html := '
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; background: #FCFAF5;">
          <div style="background: #18365D; color: white; padding: 20px; text-align: center;">
            <h1 style="margin: 0; font-size: 24px;">Welcome to The Hole Truth Project</h1>
          </div>
          <div style="padding: 30px; background: white;">
            <p>Hi ' || user_name || ',</p>
            <p>Thank you for joining our mission to promote government transparency and accountability.</p>
            <p>You can now access our interactive state map and FOIA generator tools.</p>
            <div style="text-align: center; margin: 30px 0;">
              <a href="https://theholetruth.org" style="background: #F26649; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block;">Get Started</a>
            </div>
            <p style="color: #666; font-size: 14px;">This email was sent from The Hole Truth Project.</p>
          </div>
        </div>
      ';
      
    WHEN 'recovery' THEN
      custom_html := '
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; background: #FCFAF5;">
          <div style="background: #18365D; color: white; padding: 20px; text-align: center;">
            <h1 style="margin: 0; font-size: 24px;">Reset Your Password</h1>
          </div>
          <div style="padding: 30px; background: white;">
            <p>Hi ' || user_name || ',</p>
            <p>Click the button below to reset your password:</p>
            <div style="text-align: center; margin: 30px 0;">
              <a href="' || (event->>'url') || '" style="background: #F26649; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block;">Reset Password</a>
            </div>
            <p style="color: #666; font-size: 14px;">This link will expire in 1 hour.</p>
          </div>
        </div>
      ';
      
    ELSE
      -- Use default email content
      custom_html := event->>'html';
  END CASE;
  
  -- Update the event with custom HTML
  event := jsonb_set(event, '{html}', to_jsonb(custom_html));
  
  RETURN event;
END;$$;


ALTER FUNCTION "public"."send_email_hook"("event" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_conversation_timestamp"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    UPDATE conversations 
    SET updated_at = NOW()
    WHERE id = NEW.conversation_id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_conversation_timestamp"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."States" (
    "key" "text" NOT NULL,
    "value" "jsonb" NOT NULL
);


ALTER TABLE "public"."States" OWNER TO "postgres";


COMMENT ON TABLE "public"."States" IS 'List of states and abbreviations';



CREATE TABLE IF NOT EXISTS "public"."ai_chat_messages" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "conversation_id" "uuid",
    "role" "text" NOT NULL,
    "content" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "tokens_used" integer DEFAULT 0,
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    CONSTRAINT "ai_chat_messages_role_check" CHECK (("role" = ANY (ARRAY['user'::"text", 'assistant'::"text", 'system'::"text"])))
);


ALTER TABLE "public"."ai_chat_messages" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."chat_messages" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "session_id" "uuid" NOT NULL,
    "user_id" "text" NOT NULL,
    "message_type" "text" NOT NULL,
    "content" "text" NOT NULL,
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "chat_messages_message_type_check" CHECK (("message_type" = ANY (ARRAY['user'::"text", 'assistant'::"text", 'system'::"text"])))
);


ALTER TABLE "public"."chat_messages" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."conversations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "title" "text" DEFAULT 'New Conversation'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "is_archived" boolean DEFAULT false,
    "metadata" "jsonb" DEFAULT '{}'::"jsonb"
);


ALTER TABLE "public"."conversations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."foia_requests" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "state_code" "text" NOT NULL,
    "agency_name" "text" NOT NULL,
    "request_type" "text" NOT NULL,
    "description" "text" NOT NULL,
    "generated_prompt" "text" NOT NULL,
    "status" "text" DEFAULT 'draft'::"text",
    "submitted_at" timestamp with time zone,
    "response_deadline" timestamp with time zone,
    "fees" numeric(10,2),
    "tracking_number" "text",
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "foia_requests_status_check" CHECK (("status" = ANY (ARRAY['draft'::"text", 'submitted'::"text", 'pending'::"text", 'completed'::"text", 'rejected'::"text"])))
);


ALTER TABLE "public"."foia_requests" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."foia_sessions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "text" NOT NULL,
    "state_code" "text" NOT NULL,
    "agency_name" "text",
    "request_type" "text",
    "description" "text",
    "generated_prompt" "text",
    "status" "text" DEFAULT 'draft'::"text" NOT NULL,
    "submitted_at" timestamp with time zone,
    "response_deadline" timestamp with time zone,
    "fees" numeric(10,2),
    "tracking_number" "text",
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "foia_sessions_status_check" CHECK (("status" = ANY (ARRAY['draft'::"text", 'submitted'::"text", 'pending'::"text", 'completed'::"text", 'rejected'::"text"])))
);


ALTER TABLE "public"."foia_sessions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."foia_templates" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "category" "text" NOT NULL,
    "state_code" "text" NOT NULL,
    "template" "text" NOT NULL,
    "variables" "text"[] DEFAULT '{}'::"text"[],
    "is_public" boolean DEFAULT true,
    "created_by" "uuid",
    "usage_count" integer DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."foia_templates" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."jurisdictions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "name" character varying DEFAULT 'two letter state code'::character varying,
    "statute_name" character varying DEFAULT 'Name of the statute'::character varying,
    "statute_type" character varying DEFAULT 'foia, state_foia, local_ordinance, etc.'::character varying,
    "citation" character varying DEFAULT 'legal citation'::character varying,
    "key_provisions" "text" DEFAULT 'important provisions'::"text"
);


ALTER TABLE "public"."jurisdictions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."kv_store_484e86bc" (
    "key" "text" NOT NULL,
    "value" "jsonb" NOT NULL
);


ALTER TABLE "public"."kv_store_484e86bc" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."kv_store_90468c12" (
    "key" "text" NOT NULL,
    "value" "jsonb" NOT NULL
);


ALTER TABLE "public"."kv_store_90468c12" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."kv_store_da1ef52d" (
    "key" "text" NOT NULL,
    "value" "jsonb" NOT NULL
);


ALTER TABLE "public"."kv_store_da1ef52d" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."state_agency_contacts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "state_code" "text" NOT NULL,
    "agency_name" "text" NOT NULL,
    "contact_person" "text",
    "email" "text",
    "phone" "text",
    "address" "text",
    "website" "text",
    "foia_contact" "text",
    "foia_email" "text",
    "foia_phone" "text",
    "response_time_days" integer DEFAULT 10,
    "fee_structure" "text",
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."state_agency_contacts" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."state_appeal_processes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "state_code" "text" NOT NULL,
    "appeal_steps" "text"[] NOT NULL,
    "appeal_deadline_days" integer DEFAULT 30 NOT NULL,
    "appeal_authority" "text" NOT NULL,
    "appeal_contact" "text",
    "appeal_fees" "text",
    "success_rate" numeric(5,2) DEFAULT 50.0,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."state_appeal_processes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."state_transparency_data" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "state_code" "text" NOT NULL,
    "state_name" "text" NOT NULL,
    "law_name" "text" NOT NULL,
    "law_type" "text" NOT NULL,
    "response_time_days" integer DEFAULT 10 NOT NULL,
    "success_rate" numeric(5,2) DEFAULT 65.0 NOT NULL,
    "transparency_grade" "text" NOT NULL,
    "custodian_of_records" "text" NOT NULL,
    "appeal_process" "text" NOT NULL,
    "appeal_deadline_days" integer DEFAULT 30 NOT NULL,
    "fee_structure" "text" NOT NULL,
    "exemptions" "text"[] DEFAULT '{}'::"text"[],
    "unusual_features" "text"[] DEFAULT '{}'::"text"[],
    "common_obstacles" "text"[] DEFAULT '{}'::"text"[],
    "official_portal" "text",
    "official_handbook" "text",
    "sample_requests" "text"[] DEFAULT '{}'::"text"[],
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "state_transparency_data_law_type_check" CHECK (("law_type" = ANY (ARRAY['FOIA'::"text", 'PIA'::"text", 'CPRA'::"text", 'Sunshine'::"text", 'FOIL'::"text", 'Other'::"text"]))),
    CONSTRAINT "state_transparency_data_transparency_grade_check" CHECK (("transparency_grade" = ANY (ARRAY['A'::"text", 'B'::"text", 'C'::"text", 'D'::"text", 'F'::"text"])))
);


ALTER TABLE "public"."state_transparency_data" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_profiles" (
    "id" "uuid" NOT NULL,
    "email" "text",
    "full_name" "text",
    "organization" "text",
    "phone" "text",
    "address" "text",
    "preferences" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_profiles" OWNER TO "postgres";


ALTER TABLE ONLY "public"."ai_chat_messages"
    ADD CONSTRAINT "ai_chat_messages_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."chat_messages"
    ADD CONSTRAINT "chat_messages_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."conversations"
    ADD CONSTRAINT "conversations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."foia_requests"
    ADD CONSTRAINT "foia_requests_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."foia_sessions"
    ADD CONSTRAINT "foia_sessions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."foia_templates"
    ADD CONSTRAINT "foia_templates_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."jurisdictions"
    ADD CONSTRAINT "jurisdictions_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."jurisdictions"
    ADD CONSTRAINT "jurisdictions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."kv_store_484e86bc"
    ADD CONSTRAINT "kv_store_484e86bc_pkey" PRIMARY KEY ("key");



ALTER TABLE ONLY "public"."kv_store_90468c12"
    ADD CONSTRAINT "kv_store_90468c12_pkey" PRIMARY KEY ("key");



ALTER TABLE ONLY "public"."States"
    ADD CONSTRAINT "kv_store_a405a65f_pkey" PRIMARY KEY ("key");



ALTER TABLE ONLY "public"."kv_store_da1ef52d"
    ADD CONSTRAINT "kv_store_da1ef52d_pkey" PRIMARY KEY ("key");



ALTER TABLE ONLY "public"."state_agency_contacts"
    ADD CONSTRAINT "state_agency_contacts_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."state_appeal_processes"
    ADD CONSTRAINT "state_appeal_processes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."state_appeal_processes"
    ADD CONSTRAINT "state_appeal_processes_state_code_key" UNIQUE ("state_code");



ALTER TABLE ONLY "public"."state_transparency_data"
    ADD CONSTRAINT "state_transparency_data_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."state_transparency_data"
    ADD CONSTRAINT "state_transparency_data_state_code_key" UNIQUE ("state_code");



ALTER TABLE ONLY "public"."user_profiles"
    ADD CONSTRAINT "user_profiles_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_ai_chat_messages_conversation_id" ON "public"."ai_chat_messages" USING "btree" ("conversation_id");



CREATE INDEX "idx_ai_chat_messages_created_at" ON "public"."ai_chat_messages" USING "btree" ("created_at");



CREATE INDEX "idx_chat_messages_session_id" ON "public"."chat_messages" USING "btree" ("session_id");



CREATE INDEX "idx_conversations_updated_at" ON "public"."conversations" USING "btree" ("updated_at" DESC);



CREATE INDEX "idx_conversations_user_id" ON "public"."conversations" USING "btree" ("user_id");



CREATE INDEX "idx_foia_requests_created_at" ON "public"."foia_requests" USING "btree" ("created_at");



CREATE INDEX "idx_foia_requests_state_code" ON "public"."foia_requests" USING "btree" ("state_code");



CREATE INDEX "idx_foia_requests_status" ON "public"."foia_requests" USING "btree" ("status");



CREATE INDEX "idx_foia_requests_user_id" ON "public"."foia_requests" USING "btree" ("user_id");



CREATE INDEX "idx_foia_sessions_state_code" ON "public"."foia_sessions" USING "btree" ("state_code");



CREATE INDEX "idx_foia_sessions_user_id" ON "public"."foia_sessions" USING "btree" ("user_id");



CREATE INDEX "idx_foia_templates_category" ON "public"."foia_templates" USING "btree" ("category");



CREATE INDEX "idx_foia_templates_is_public" ON "public"."foia_templates" USING "btree" ("is_public");



CREATE INDEX "idx_foia_templates_state_code" ON "public"."foia_templates" USING "btree" ("state_code");



CREATE INDEX "idx_state_transparency_data_grade" ON "public"."state_transparency_data" USING "btree" ("transparency_grade");



CREATE INDEX "idx_state_transparency_data_state_code" ON "public"."state_transparency_data" USING "btree" ("state_code");



CREATE INDEX "kv_store_484e86bc_key_idx" ON "public"."kv_store_484e86bc" USING "btree" ("key" "text_pattern_ops");



CREATE INDEX "kv_store_484e86bc_key_idx1" ON "public"."kv_store_484e86bc" USING "btree" ("key" "text_pattern_ops");



CREATE INDEX "kv_store_90468c12_key_idx" ON "public"."kv_store_90468c12" USING "btree" ("key" "text_pattern_ops");



CREATE INDEX "kv_store_90468c12_key_idx1" ON "public"."kv_store_90468c12" USING "btree" ("key" "text_pattern_ops");



CREATE INDEX "kv_store_90468c12_key_idx2" ON "public"."kv_store_90468c12" USING "btree" ("key" "text_pattern_ops");



CREATE INDEX "kv_store_90468c12_key_idx3" ON "public"."kv_store_90468c12" USING "btree" ("key" "text_pattern_ops");



CREATE INDEX "kv_store_90468c12_key_idx4" ON "public"."kv_store_90468c12" USING "btree" ("key" "text_pattern_ops");



CREATE INDEX "kv_store_90468c12_key_idx5" ON "public"."kv_store_90468c12" USING "btree" ("key" "text_pattern_ops");



CREATE INDEX "kv_store_90468c12_key_idx6" ON "public"."kv_store_90468c12" USING "btree" ("key" "text_pattern_ops");



CREATE INDEX "kv_store_a405a65f_key_idx" ON "public"."States" USING "btree" ("key" "text_pattern_ops");



CREATE INDEX "kv_store_a405a65f_key_idx1" ON "public"."States" USING "btree" ("key" "text_pattern_ops");



CREATE INDEX "kv_store_a405a65f_key_idx2" ON "public"."States" USING "btree" ("key" "text_pattern_ops");



CREATE INDEX "kv_store_a405a65f_key_idx3" ON "public"."States" USING "btree" ("key" "text_pattern_ops");



CREATE INDEX "kv_store_a405a65f_key_idx4" ON "public"."States" USING "btree" ("key" "text_pattern_ops");



CREATE INDEX "kv_store_a405a65f_key_idx5" ON "public"."States" USING "btree" ("key" "text_pattern_ops");



CREATE INDEX "kv_store_da1ef52d_key_idx" ON "public"."kv_store_da1ef52d" USING "btree" ("key" "text_pattern_ops");



CREATE INDEX "kv_store_da1ef52d_key_idx1" ON "public"."kv_store_da1ef52d" USING "btree" ("key" "text_pattern_ops");



CREATE OR REPLACE TRIGGER "update_conversation_on_message" AFTER INSERT ON "public"."ai_chat_messages" FOR EACH ROW EXECUTE FUNCTION "public"."update_conversation_timestamp"();



CREATE OR REPLACE TRIGGER "update_foia_requests_updated_at" BEFORE UPDATE ON "public"."foia_requests" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_foia_templates_updated_at" BEFORE UPDATE ON "public"."foia_templates" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_user_profiles_updated_at" BEFORE UPDATE ON "public"."user_profiles" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



ALTER TABLE ONLY "public"."ai_chat_messages"
    ADD CONSTRAINT "ai_chat_messages_conversation_id_fkey" FOREIGN KEY ("conversation_id") REFERENCES "public"."conversations"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."chat_messages"
    ADD CONSTRAINT "chat_messages_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "public"."foia_sessions"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."conversations"
    ADD CONSTRAINT "conversations_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."foia_requests"
    ADD CONSTRAINT "foia_requests_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."foia_templates"
    ADD CONSTRAINT "foia_templates_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."user_profiles"
    ADD CONSTRAINT "user_profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



CREATE POLICY "Allow authenticated users to read data" ON "public"."States" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow read access for all users" ON "public"."jurisdictions" FOR SELECT USING (true);



CREATE POLICY "Allow read access to transparency data" ON "public"."state_transparency_data" FOR SELECT USING (true);



CREATE POLICY "Allow temporary development access" ON "public"."States" TO "authenticated", "anon" USING (true);



CREATE POLICY "Allow updates for authenticated users" ON "public"."state_transparency_data" TO "authenticated" USING (true) WITH CHECK (true);



CREATE POLICY "Anyone can view public templates" ON "public"."foia_templates" FOR SELECT USING (("is_public" = true));



CREATE POLICY "Authenticated users can read kv_store_484e86bc" ON "public"."kv_store_484e86bc" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Authenticated users can read kv_store_90468c12" ON "public"."kv_store_90468c12" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Authenticated users can read kv_store_da1ef52d" ON "public"."kv_store_da1ef52d" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Public read access to state agency contacts" ON "public"."state_agency_contacts" FOR SELECT USING (true);



CREATE POLICY "Public read access to state appeal processes" ON "public"."state_appeal_processes" FOR SELECT USING (true);



CREATE POLICY "Service role can manage kv_store_484e86bc" ON "public"."kv_store_484e86bc" USING (("auth"."role"() = 'service_role'::"text"));



CREATE POLICY "Service role can manage kv_store_90468c12" ON "public"."kv_store_90468c12" USING (("auth"."role"() = 'service_role'::"text"));



CREATE POLICY "Service role can manage kv_store_da1ef52d" ON "public"."kv_store_da1ef52d" USING (("auth"."role"() = 'service_role'::"text"));



ALTER TABLE "public"."States" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "Users can create messages in their conversations" ON "public"."ai_chat_messages" FOR INSERT WITH CHECK (("conversation_id" IN ( SELECT "conversations"."id"
   FROM "public"."conversations"
  WHERE ("conversations"."user_id" = "auth"."uid"()))));



CREATE POLICY "Users can create templates" ON "public"."foia_templates" FOR INSERT WITH CHECK (("auth"."uid"() = "created_by"));



CREATE POLICY "Users can create their own conversations" ON "public"."conversations" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can delete their own FOIA requests" ON "public"."foia_requests" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can delete their own conversations" ON "public"."conversations" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can delete their own templates" ON "public"."foia_templates" FOR DELETE USING (("auth"."uid"() = "created_by"));



CREATE POLICY "Users can insert their own FOIA requests" ON "public"."foia_requests" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert their own profile" ON "public"."user_profiles" FOR INSERT WITH CHECK (("auth"."uid"() = "id"));



CREATE POLICY "Users can manage their own FOIA sessions" ON "public"."foia_sessions" USING ((("auth"."uid"())::"text" = "user_id"));



CREATE POLICY "Users can manage their own chat messages" ON "public"."chat_messages" USING ((("auth"."uid"())::"text" = "user_id"));



CREATE POLICY "Users can update their own FOIA requests" ON "public"."foia_requests" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own conversations" ON "public"."conversations" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own profile" ON "public"."user_profiles" FOR UPDATE USING (("auth"."uid"() = "id"));



CREATE POLICY "Users can update their own templates" ON "public"."foia_templates" FOR UPDATE USING (("auth"."uid"() = "created_by"));



CREATE POLICY "Users can view messages in their conversations" ON "public"."ai_chat_messages" FOR SELECT USING (("conversation_id" IN ( SELECT "conversations"."id"
   FROM "public"."conversations"
  WHERE ("conversations"."user_id" = "auth"."uid"()))));



CREATE POLICY "Users can view their own FOIA requests" ON "public"."foia_requests" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view their own conversations" ON "public"."conversations" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view their own profile" ON "public"."user_profiles" FOR SELECT USING (("auth"."uid"() = "id"));



CREATE POLICY "Users can view their own templates" ON "public"."foia_templates" FOR SELECT USING (("auth"."uid"() = "created_by"));



ALTER TABLE "public"."ai_chat_messages" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."chat_messages" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."conversations" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."foia_requests" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."foia_sessions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."foia_templates" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."jurisdictions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."kv_store_484e86bc" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."kv_store_90468c12" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."kv_store_da1ef52d" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."state_agency_contacts" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."state_appeal_processes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."state_transparency_data" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_profiles" ENABLE ROW LEVEL SECURITY;


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";
GRANT USAGE ON SCHEMA "public" TO "supabase_auth_admin";



REVOKE ALL ON FUNCTION "public"."before_user_created_hook"("event" "jsonb") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."before_user_created_hook"("event" "jsonb") TO "service_role";
GRANT ALL ON FUNCTION "public"."before_user_created_hook"("event" "jsonb") TO "supabase_auth_admin";



REVOKE ALL ON FUNCTION "public"."custom_access_token_hook"("event" "jsonb") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."custom_access_token_hook"("event" "jsonb") TO "service_role";
GRANT ALL ON FUNCTION "public"."custom_access_token_hook"("event" "jsonb") TO "supabase_auth_admin";



GRANT ALL ON FUNCTION "public"."increment_template_usage"("template_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."increment_template_usage"("template_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."increment_template_usage"("template_id" "uuid") TO "service_role";



REVOKE ALL ON FUNCTION "public"."send_email_hook"("event" "jsonb") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."send_email_hook"("event" "jsonb") TO "service_role";
GRANT ALL ON FUNCTION "public"."send_email_hook"("event" "jsonb") TO "supabase_auth_admin";



GRANT ALL ON FUNCTION "public"."update_conversation_timestamp"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_conversation_timestamp"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_conversation_timestamp"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "service_role";



GRANT ALL ON TABLE "public"."States" TO "anon";
GRANT ALL ON TABLE "public"."States" TO "authenticated";
GRANT ALL ON TABLE "public"."States" TO "service_role";



GRANT ALL ON TABLE "public"."ai_chat_messages" TO "anon";
GRANT ALL ON TABLE "public"."ai_chat_messages" TO "authenticated";
GRANT ALL ON TABLE "public"."ai_chat_messages" TO "service_role";



GRANT ALL ON TABLE "public"."chat_messages" TO "anon";
GRANT ALL ON TABLE "public"."chat_messages" TO "authenticated";
GRANT ALL ON TABLE "public"."chat_messages" TO "service_role";



GRANT ALL ON TABLE "public"."conversations" TO "anon";
GRANT ALL ON TABLE "public"."conversations" TO "authenticated";
GRANT ALL ON TABLE "public"."conversations" TO "service_role";



GRANT ALL ON TABLE "public"."foia_requests" TO "anon";
GRANT ALL ON TABLE "public"."foia_requests" TO "authenticated";
GRANT ALL ON TABLE "public"."foia_requests" TO "service_role";



GRANT ALL ON TABLE "public"."foia_sessions" TO "anon";
GRANT ALL ON TABLE "public"."foia_sessions" TO "authenticated";
GRANT ALL ON TABLE "public"."foia_sessions" TO "service_role";



GRANT ALL ON TABLE "public"."foia_templates" TO "anon";
GRANT ALL ON TABLE "public"."foia_templates" TO "authenticated";
GRANT ALL ON TABLE "public"."foia_templates" TO "service_role";



GRANT ALL ON TABLE "public"."jurisdictions" TO "anon";
GRANT ALL ON TABLE "public"."jurisdictions" TO "authenticated";
GRANT ALL ON TABLE "public"."jurisdictions" TO "service_role";



GRANT ALL ON TABLE "public"."kv_store_484e86bc" TO "anon";
GRANT ALL ON TABLE "public"."kv_store_484e86bc" TO "authenticated";
GRANT ALL ON TABLE "public"."kv_store_484e86bc" TO "service_role";



GRANT ALL ON TABLE "public"."kv_store_90468c12" TO "anon";
GRANT ALL ON TABLE "public"."kv_store_90468c12" TO "authenticated";
GRANT ALL ON TABLE "public"."kv_store_90468c12" TO "service_role";



GRANT ALL ON TABLE "public"."kv_store_da1ef52d" TO "anon";
GRANT ALL ON TABLE "public"."kv_store_da1ef52d" TO "authenticated";
GRANT ALL ON TABLE "public"."kv_store_da1ef52d" TO "service_role";



GRANT ALL ON TABLE "public"."state_agency_contacts" TO "anon";
GRANT ALL ON TABLE "public"."state_agency_contacts" TO "authenticated";
GRANT ALL ON TABLE "public"."state_agency_contacts" TO "service_role";



GRANT ALL ON TABLE "public"."state_appeal_processes" TO "anon";
GRANT ALL ON TABLE "public"."state_appeal_processes" TO "authenticated";
GRANT ALL ON TABLE "public"."state_appeal_processes" TO "service_role";



GRANT ALL ON TABLE "public"."state_transparency_data" TO "anon";
GRANT ALL ON TABLE "public"."state_transparency_data" TO "authenticated";
GRANT ALL ON TABLE "public"."state_transparency_data" TO "service_role";



GRANT ALL ON TABLE "public"."user_profiles" TO "anon";
GRANT ALL ON TABLE "public"."user_profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."user_profiles" TO "service_role";



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






RESET ALL;
