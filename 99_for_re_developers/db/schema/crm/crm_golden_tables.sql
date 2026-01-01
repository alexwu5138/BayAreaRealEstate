-- ============================================================
-- CRM Golden Record Tables (Pluralized, crm.* namespace)
-- Target: MySQL 8.x / MariaDB 10.x
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS crm.persons (
  person_id        BIGINT AUTO_INCREMENT PRIMARY KEY,
  is_organization  TINYINT NOT NULL DEFAULT 0,
  display_name     VARCHAR(255) NULL,
  preferred_name   VARCHAR(100) NULL,
  notes            TEXT NULL,
  created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_persons_display_name (display_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS crm.person_names (
  person_id    BIGINT NOT NULL,
  first_name   VARCHAR(100) NULL,
  last_name    VARCHAR(100) NULL,
  middle_name  VARCHAR(100) NULL,
  suffix       VARCHAR(50)  NULL,
  title        VARCHAR(100) NULL,
  is_primary   TINYINT NOT NULL DEFAULT 1,
  created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (person_id, is_primary),
  CONSTRAINT fk_person_names_persons
    FOREIGN KEY (person_id) REFERENCES crm.persons(person_id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS crm.person_emails (
  person_email_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  person_id       BIGINT NOT NULL,
  email           VARCHAR(255) NOT NULL,
  label           VARCHAR(30) NULL,
  is_primary      TINYINT NOT NULL DEFAULT 0,
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_person_emails_email (email),
  KEY idx_person_emails_person (person_id),
  CONSTRAINT fk_person_emails_persons
    FOREIGN KEY (person_id) REFERENCES crm.persons(person_id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS crm.person_phones (
  person_phone_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  person_id       BIGINT NOT NULL,
  phone_e164      VARCHAR(20) NOT NULL,
  label           VARCHAR(30) NULL,
  is_primary      TINYINT NOT NULL DEFAULT 0,
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_person_phones_e164 (phone_e164),
  KEY idx_person_phones_person (person_id),
  CONSTRAINT fk_person_phones_persons
    FOREIGN KEY (person_id) REFERENCES crm.persons(person_id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS crm.person_addresses (
  person_address_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  person_id         BIGINT NOT NULL,
  street            VARCHAR(255) NULL,
  suite_apt         VARCHAR(100) NULL,
  city              VARCHAR(100) NULL,
  state             CHAR(2) NULL,
  postal_code       VARCHAR(20) NULL,
  country           CHAR(2) NULL DEFAULT 'US',
  label             VARCHAR(30) NULL,
  is_primary        TINYINT NOT NULL DEFAULT 0,
  created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_person_addresses_person (person_id),
  CONSTRAINT fk_person_addresses_persons
    FOREIGN KEY (person_id) REFERENCES crm.persons(person_id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS crm.person_organizations (
  person_organization_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  person_id              BIGINT NOT NULL,
  org_name               VARCHAR(255) NULL,
  title                  VARCHAR(100) NULL,
  department             VARCHAR(100) NULL,
  is_primary             TINYINT NOT NULL DEFAULT 0,
  created_at             TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at             TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_person_orgs_person (person_id),
  CONSTRAINT fk_person_orgs_persons
    FOREIGN KEY (person_id) REFERENCES crm.persons(person_id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS crm.tags (
  tag_id      BIGINT AUTO_INCREMENT PRIMARY KEY,
  tag_name    VARCHAR(100) NOT NULL,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_tags_name (tag_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS crm.person_tags (
  person_id BIGINT NOT NULL,
  tag_id    BIGINT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (person_id, tag_id),
  CONSTRAINT fk_person_tags_persons
    FOREIGN KEY (person_id) REFERENCES crm.persons(person_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_person_tags_tags
    FOREIGN KEY (tag_id) REFERENCES crm.tags(tag_id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS crm.person_source_links (
  person_source_link_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  person_id         BIGINT NOT NULL,
  source_contact_id BIGINT NOT NULL,
  match_method      VARCHAR(30) NOT NULL,
  confidence        INT NOT NULL DEFAULT 0,
  matched_on        VARCHAR(300) NULL,
  linked_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  is_active         TINYINT NOT NULL DEFAULT 1,
  UNIQUE KEY uq_psl_source_contact (source_contact_id),
  KEY idx_psl_person (person_id),
  CONSTRAINT fk_psl_persons
    FOREIGN KEY (person_id) REFERENCES crm.persons(person_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_psl_source_contacts
    FOREIGN KEY (source_contact_id) REFERENCES crm.source_contacts(source_contact_id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS crm.match_review_queues (
  review_id           BIGINT AUTO_INCREMENT PRIMARY KEY,
  source_contact_id   BIGINT NOT NULL,
  candidate_person_id BIGINT NULL,
  score               DECIMAL(5,2) NULL,
  reason              VARCHAR(255) NULL,
  status              VARCHAR(30) NOT NULL DEFAULT 'open',
  created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_mrq_status (status),
  CONSTRAINT fk_mrq_source_contacts
    FOREIGN KEY (source_contact_id) REFERENCES crm.source_contacts(source_contact_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_mrq_candidate_persons
    FOREIGN KEY (candidate_person_id) REFERENCES crm.persons(person_id)
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
