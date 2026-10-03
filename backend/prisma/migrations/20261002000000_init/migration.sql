-- CreateEnum
CREATE TYPE "estatus" AS ENUM ('ACTIVE', 'INACTIVE');

-- CreateTable
CREATE TABLE "users" (
    "id" BIGSERIAL NOT NULL,
    "username" VARCHAR(160),
    "email" VARCHAR(160) NOT NULL,
    "password" VARCHAR(250) NOT NULL,
    "status" "estatus" NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "episodes" (
    "id" BIGSERIAL NOT NULL,
    "name" VARCHAR(150) NOT NULL,
    "description" TEXT,
    "first_chapter_id" BIGINT,
    "create_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "update_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "status" "estatus" NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "episodes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "chapters" (
    "id" BIGSERIAL NOT NULL,
    "episode_id" BIGINT NOT NULL,
    "video_url" TEXT NOT NULL,
    "description" TEXT,
    "question" TEXT,
    "create_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "update_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "chapters_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "answers" (
    "id" BIGSERIAL NOT NULL,
    "chapter_id" BIGINT NOT NULL,
    "intent" VARCHAR(100),
    "keywords" TEXT[],
    "next_chapter_id" BIGINT,
    "create_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "answers_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_username_key" ON "users"("username");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- AddForeignKey
ALTER TABLE "answers" ADD CONSTRAINT "fk_answer_chapter" FOREIGN KEY ("chapter_id") REFERENCES "chapters"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "answers" ADD CONSTRAINT "fk_answer_next_chapter" FOREIGN KEY ("next_chapter_id") REFERENCES "chapters"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "chapters" ADD CONSTRAINT "fk_chapter_episode" FOREIGN KEY ("episode_id") REFERENCES "episodes"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "episodes" ADD CONSTRAINT "fk_episode_first_chapter" FOREIGN KEY ("first_chapter_id") REFERENCES "chapters"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
