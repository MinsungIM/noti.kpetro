CREATE TABLE "asset_history" (
	"id" varchar PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"asset_id" varchar NOT NULL,
	"user_id" varchar,
	"change_type" text NOT NULL,
	"field_name" text,
	"old_value" text,
	"new_value" text,
	"date" timestamp DEFAULT now() NOT NULL,
	"notes" text
);
--> statement-breakpoint
CREATE TABLE "assets" (
	"id" varchar PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" text NOT NULL,
	"serial_number" text NOT NULL,
	"category_id" varchar,
	"team_id" varchar NOT NULL,
	"manager_id" varchar NOT NULL,
	"usage_team_id" varchar NOT NULL,
	"staff_id" varchar NOT NULL,
	"inspection_cycle_days" integer NOT NULL,
	"last_inspected_date" text NOT NULL,
	"next_due_date" text NOT NULL,
	"status" text NOT NULL,
	"suspended_reason" text,
	"notes" text,
	CONSTRAINT "assets_serial_number_unique" UNIQUE("serial_number")
);
--> statement-breakpoint
CREATE TABLE "categories" (
	"id" varchar PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" text NOT NULL,
	"manager_ids" text[] DEFAULT '{}'::text[],
	"default_cycle_days" integer,
	CONSTRAINT "categories_name_unique" UNIQUE("name")
);
--> statement-breakpoint
CREATE TABLE "inspection_logs" (
	"id" varchar PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"asset_id" varchar NOT NULL,
	"inspector_id" varchar NOT NULL,
	"date" timestamp DEFAULT now() NOT NULL,
	"notes" text NOT NULL
);
--> statement-breakpoint
CREATE TABLE "personal_tasks" (
	"id" varchar PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" varchar NOT NULL,
	"title" text NOT NULL,
	"description" text,
	"scheduled_at" text NOT NULL,
	"repeat_type" text DEFAULT 'none' NOT NULL,
	"completed" boolean DEFAULT false NOT NULL,
	"share_scope" text DEFAULT 'private' NOT NULL,
	"share_team_ids" text[] DEFAULT '{}'::text[],
	"share_user_ids" text[] DEFAULT '{}'::text[],
	"scheduled_end_at" text,
	"last_morning_notified_date" text,
	"label" text,
	"priority" integer DEFAULT 0 NOT NULL,
	"reminder_notified" boolean DEFAULT false NOT NULL,
	"email_digest_sent" boolean DEFAULT false NOT NULL,
	"created_at" text NOT NULL
);
--> statement-breakpoint
CREATE TABLE "push_subscriptions" (
	"id" varchar PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" varchar NOT NULL,
	"endpoint" text NOT NULL,
	"p256dh" text NOT NULL,
	"auth" text NOT NULL,
	"created_at" text NOT NULL
);
--> statement-breakpoint
CREATE TABLE "sessions" (
	"sid" varchar PRIMARY KEY NOT NULL,
	"sess" jsonb NOT NULL,
	"expire" timestamp NOT NULL
);
--> statement-breakpoint
CREATE TABLE "system_settings" (
	"key" text PRIMARY KEY NOT NULL,
	"value" text NOT NULL
);
--> statement-breakpoint
CREATE TABLE "teams" (
	"id" varchar PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" text NOT NULL,
	"department" text,
	"type" text DEFAULT 'management' NOT NULL,
	"contact_email" text,
	"phone" text,
	"staff_email" text,
	"staff_phone" text
);
--> statement-breakpoint
CREATE TABLE "users" (
	"id" varchar PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"username" text NOT NULL,
	"full_name" text,
	"role" text NOT NULL,
	"team_id" varchar NOT NULL,
	"manager_id" varchar,
	"assigned_category_ids" text[] DEFAULT '{}'::text[],
	"position" text,
	"email" text,
	"phone" text,
	"password_hash" text,
	"privacy_consent_at" text,
	"optional_consent_at" text,
	"optional_consent_given" boolean DEFAULT false,
	CONSTRAINT "users_username_unique" UNIQUE("username")
);
--> statement-breakpoint
ALTER TABLE "assets" ADD CONSTRAINT "assets_team_id_teams_id_fk" FOREIGN KEY ("team_id") REFERENCES "public"."teams"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "assets" ADD CONSTRAINT "assets_manager_id_users_id_fk" FOREIGN KEY ("manager_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "assets" ADD CONSTRAINT "assets_usage_team_id_teams_id_fk" FOREIGN KEY ("usage_team_id") REFERENCES "public"."teams"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "assets" ADD CONSTRAINT "assets_staff_id_users_id_fk" FOREIGN KEY ("staff_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "inspection_logs" ADD CONSTRAINT "inspection_logs_asset_id_assets_id_fk" FOREIGN KEY ("asset_id") REFERENCES "public"."assets"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "inspection_logs" ADD CONSTRAINT "inspection_logs_inspector_id_users_id_fk" FOREIGN KEY ("inspector_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "users" ADD CONSTRAINT "users_team_id_teams_id_fk" FOREIGN KEY ("team_id") REFERENCES "public"."teams"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "IDX_session_expire" ON "sessions" USING btree ("expire");