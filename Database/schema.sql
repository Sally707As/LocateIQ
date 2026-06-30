-- 1) Create Users table
create table if not exists "Users" (
  "userID" BIGSERIAL primary key,
  "name" TEXT not null,
  "email" TEXT not null unique,
  "password" TEXT not null,
  "language" TEXT default 'ar',
  "registrationDate" TIMESTAMPTZ default now()
);

-- (Optional) index for faster lookups by email
create index IF not exists idx_users_email on "Users" ("email");

alter table "Users"
add column "phoneNumber" TEXT,
add column "nationalID" TEXT,
add column "birthDate" DATE;

alter table "Users"
add column "profileImage" TEXT;

-- 2) Create Investor table
CREATE TABLE  "Investor" (
  "investorID" BIGSERIAL PRIMARY KEY,
  "userID" BIGINT NOT NULL UNIQUE,
  "investmentType" TEXT,
  "region" TEXT,
  "license" TEXT,

  CONSTRAINT fk_investor_user
    FOREIGN KEY ("userID")
    REFERENCES "Users" ("userID")
    ON DELETE CASCADE
);


-- 3) Create Admin table
CREATE TABLE  "Admin" (
  "adminID" BIGSERIAL PRIMARY KEY,
  "userID" BIGINT NOT NULL UNIQUE,
  "role" TEXT,
  "permissions" TEXT,

  CONSTRAINT fk_admin_user
    FOREIGN KEY ("userID")
    REFERENCES "Users" ("userID")
    ON DELETE CASCADE
);

ALTER TABLE "Admin"
ADD COLUMN "siteName" TEXT,
ADD COLUMN "adminEmail" TEXT,
ADD COLUMN "maintenanceMode" BOOLEAN DEFAULT false,
ADD COLUMN "mapStyle" TEXT,
ADD COLUMN "zoomLevel" INTEGER,
ADD COLUMN "showClusters" BOOLEAN DEFAULT true;


-- 4) Create AIChatAnalysis table
CREATE TABLE IF NOT EXISTS "AIChatAnalysis" (
  "chatID" BIGSERIAL PRIMARY KEY,
  "userID" BIGINT NOT NULL,
  "message" TEXT NOT NULL,
  "aiResponse" TEXT NOT NULL,
  "confidenceScore" NUMERIC(5,2),
  "timestamp" TIMESTAMPTZ DEFAULT now(),

  CONSTRAINT fk_chat_user
    FOREIGN KEY ("userID")
    REFERENCES "Users" ("userID")
    ON DELETE CASCADE
);

-- Helpful index for retrieving user's latest chats
CREATE INDEX IF NOT EXISTS idx_chat_user_time
ON "AIChatAnalysis" ("userID", "timestamp" DESC);

-- 5) Create DisplaySearch table
CREATE TABLE IF NOT EXISTS "DisplaySearch" (
  "searchID" BIGSERIAL PRIMARY KEY,
  "userID" BIGINT NOT NULL,
  "score" NUMERIC(6,2),
  "resultNumber" INTEGER,
  "date" DATE DEFAULT CURRENT_DATE,
  "timestamp" TIMESTAMPTZ DEFAULT now(),

  CONSTRAINT fk_search_user
    FOREIGN KEY ("userID")
    REFERENCES "Users" ("userID")
    ON DELETE CASCADE
);

-- Index for fast retrieval of user's previous results
CREATE INDEX IF NOT EXISTS idx_displaysearch_user
ON "DisplaySearch" ("userID");

SELECT "score", "resultNumber", "timestamp"
FROM "DisplaySearch"
WHERE "userID" = 1
ORDER BY "timestamp" DESC
LIMIT 10;

CREATE TABLE "LIQDataset"

INSERT INTO "LIQDataset"
("city","neighborhood","geom","populationDensity","competitorsCount","servicesCount")
SELECT
  city,
  neighborhood,
  geom,
  population_density,
  competitors_count,
  services_count
FROM "LocateIQ_Dataset_Final";

