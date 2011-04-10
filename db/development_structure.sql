CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL);
CREATE TABLE "tweets" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "external_id" varchar(50), "posted_at" datetime, "in_reply_to_user_id" integer, "source" varchar(50), "user_id" integer, "user_name" varchar(50), "user_screen_name" varchar(50), "text" text, "created_at" datetime, "raw" text, "type" varchar(50), "updated_at" datetime);
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
INSERT INTO schema_migrations (version) VALUES ('20110410071832');

INSERT INTO schema_migrations (version) VALUES ('20110410074019');