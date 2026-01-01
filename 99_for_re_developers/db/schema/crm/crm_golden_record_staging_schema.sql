-- ============================================================
-- CRM Golden Record Staging Schema (Pluralized Tables)
-- Target: MySQL 8.x / MariaDB 10.x
-- Database: crm
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 1. Source systems
-- ============================================================
CREATE TABLE IF NOT EXISTS crm.source_systems (
  source_system_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name             VARCHAR(50) NOT NULL,
  priority         INT NOT NULL DEFAULT 0,
  created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_source_systems_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 2. Import batches
-- ============================================================
CREATE TABLE IF NOT EXISTS crm.source_import_batches (
  batch_id         BIGINT AUTO_INCREMENT PRIMARY KEY,
  source_system_id BIGINT NOT NULL,
  filename         VARCHAR(255) NULL,
  imported_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  row_count        INT NULL,
  notes            VARCHAR(255) NULL,
  CONSTRAINT fk_sib_source_systems
    FOREIGN KEY (source_system_id)
    REFERENCES crm.source_systems(source_system_id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 3. Source contacts (staging, merge-safe)
-- ============================================================
CREATE TABLE IF NOT EXISTS crm.source_contacts (
  source_contact_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  source_system_id  BIGINT NOT NULL,
  external_id       VARCHAR(200) NULL,
  natural_key       VARCHAR(300) NOT NULL,
  payload_hash      CHAR(64) NOT NULL,
  raw_payload       JSON NULL,
  first_seen_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_seen_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  last_batch_id     BIGINT NULL,

  UNIQUE KEY uq_sc_source_natural (source_system_id, natural_key),
  KEY idx_sc_source_external (source_system_id, external_id),

  CONSTRAINT fk_sc_source_systems
    FOREIGN KEY (source_system_id)
    REFERENCES crm.source_systems(source_system_id)
    ON DELETE CASCADE,

  CONSTRAINT fk_sc_last_batch
    FOREIGN KEY (last_batch_id)
    REFERENCES crm.source_import_batches(batch_id)
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 4. Categories
-- ============================================================
CREATE TABLE IF NOT EXISTS crm.categories (
  category_id   BIGINT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(100) NOT NULL,
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_categories_name (category_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 5. Source contact categories (join table)
-- ============================================================
CREATE TABLE IF NOT EXISTS crm.source_contact_categories (
  source_contact_id BIGINT NOT NULL,
  category_id       BIGINT NOT NULL,

  PRIMARY KEY (source_contact_id, category_id),

  CONSTRAINT fk_scc_source_contacts
    FOREIGN KEY (source_contact_id)
    REFERENCES crm.source_contacts(source_contact_id)
    ON DELETE CASCADE,

  CONSTRAINT fk_scc_categories
    FOREIGN KEY (category_id)
    REFERENCES crm.categories(category_id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
