DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE t.typname = 'estatus' AND n.nspname = 'public') THEN
        CREATE TYPE estatus AS ENUM ('ACTIVE','INACTIVE');
    END IF;
END$$;

CREATE TABLE episodes (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    first_chapter_id BIGINT,
    create_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    update_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status estatus NOT NULL DEFAULT 'ACTIVE'
);

CREATE TABLE chapters (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    episode_id BIGINT NOT NULL,
    video_url TEXT NOT NULL,
    description TEXT,
    question TEXT,
    create_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    update_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_chapter_episode
        FOREIGN KEY (episode_id)
        REFERENCES episodes(id)
);

CREATE TABLE answers (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    chapter_id BIGINT NOT NULL,
    intent VARCHAR(100),
    keywords TEXT[],
    next_chapter_id BIGINT,
    create_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_answer_chapter
        FOREIGN KEY (chapter_id)
        REFERENCES chapters(id),

    CONSTRAINT fk_answer_next_chapter
        FOREIGN KEY (next_chapter_id)
        REFERENCES chapters(id)
);

ALTER TABLE episodes
ADD CONSTRAINT fk_episode_first_chapter
FOREIGN KEY (first_chapter_id)
REFERENCES chapters(id);