SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
--SET row_security = off;


CREATE SCHEMA contactfaune;


SET search_path = contactfaune, pg_catalog;
SET default_with_oids = false;

------------------------
--TABLES AND SEQUENCES--
------------------------
CREATE TABLE cor_role_releve_cfaune (
    id_releve_cfaune bigint NOT NULL,
    id_role integer NOT NULL
);


CREATE TABLE cor_stade_sexe_effectif (
    id_occurence_cfaune bigint NOT NULL,
    id_nomenclature_stade_vie integer NOT NULL,
    id_nomenclature_sexe integer NOT NULL,
    effectif integer
);


CREATE TABLE t_releves_cfaune (
    id_releve_cfaune bigint NOT NULL,
    id_lot integer NOT NULL,
    id_nomenclature_technique_obs integer NOT NULL DEFAULT 343,
    id_nomenclature_eta_bio integer NOT NULL DEFAULT 177,
    id_numerisateur integer,
    date_min date NOT NULL,
    date_max date NOT NULL,
    heure_obs integer,
    insee character(5),
    altitude_min integer,
    altitude_max integer,
    saisie_initiale character varying(20),
    supprime boolean DEFAULT false NOT NULL,
    date_insert timestamp without time zone DEFAULT now(),
    date_update timestamp without time zone DEFAULT now(),
    commentaire text,
    the_geom_local public.geometry(Geometry,2154),
    the_geom_3857 public.geometry(Geometry,3857),
    CONSTRAINT enforce_dims_the_geom_3857 CHECK ((public.st_ndims(the_geom_3857) = 2)),
    CONSTRAINT enforce_dims_the_geom_local CHECK ((public.st_ndims(the_geom_local) = 2)),
    CONSTRAINT enforce_srid_the_geom_3857 CHECK ((public.st_srid(the_geom_3857) = 3857)),
    CONSTRAINT enforce_srid_the_geom_local CHECK ((public.st_srid(the_geom_local) = 2154))
);

CREATE SEQUENCE t_releves_cfaune_id_releve_cfaune_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE t_releves_cfaune_id_releve_cfaune_seq OWNED BY t_releves_cfaune.id_releve_cfaune;
ALTER TABLE ONLY t_releves_cfaune ALTER COLUMN id_releve_cfaune SET DEFAULT nextval('t_releves_cfaune_id_releve_cfaune_seq'::regclass);
SELECT pg_catalog.setval('t_releves_cfaune_id_releve_cfaune_seq', 1, false);


CREATE TABLE t_occurences_cfaune (
    id_occurence_cfaune bigint NOT NULL,
    id_releve_cfaune bigint NOT NULL,
    id_nomenclature_meth_obs integer DEFAULT 42,
    id_nomenclature_statut_bio integer DEFAULT 30,
    id_valideur integer,
    determinateur character varying(255),
    cd_nom integer,
    nom_cite character varying(255),
    v_taxref integer,
    num_prelevement_cfaune text,
    validition integer,
    supprime boolean DEFAULT false NOT NULL,
    date_insert timestamp without time zone,
    date_update timestamp without time zone,
    commentaire character varying
);

CREATE SEQUENCE t_occurences_cfaune_id_occurence_cfaune_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE t_occurences_cfaune_id_occurence_cfaune_seq OWNED BY t_occurences_cfaune.id_occurence_cfaune;
ALTER TABLE ONLY t_occurences_cfaune ALTER COLUMN id_occurence_cfaune SET DEFAULT nextval('t_occurences_cfaune_id_occurence_cfaune_seq'::regclass);
SELECT pg_catalog.setval('t_occurences_cfaune_id_occurence_cfaune_seq', 1, false);

---------------
--PRIMARY KEY--
---------------
ALTER TABLE ONLY cor_role_releve_cfaune
    ADD CONSTRAINT pk_cor_role_releve_cfaune PRIMARY KEY (id_releve_cfaune, id_role);

ALTER TABLE ONLY cor_stade_sexe_effectif
    ADD CONSTRAINT pk_cor_stade_sexe_effectif_cfaune PRIMARY KEY (id_occurence_cfaune, id_nomenclature_stade_vie, id_nomenclature_sexe);

ALTER TABLE ONLY t_occurences_cfaune
    ADD CONSTRAINT pk_t_occurences_cfaune PRIMARY KEY (id_occurence_cfaune);

ALTER TABLE ONLY t_releves_cfaune
    ADD CONSTRAINT pk_t_releves_cfaune PRIMARY KEY (id_releve_cfaune);


---------------
--FOREIGN KEY--
---------------
ALTER TABLE ONLY cor_role_releve_cfaune
    ADD CONSTRAINT fk_cor_role_releve_cfaune_t_releves_cfaune FOREIGN KEY (id_releve_cfaune) REFERENCES t_releves_cfaune(id_releve_cfaune) ON UPDATE CASCADE;

ALTER TABLE ONLY cor_role_releve_cfaune
    ADD CONSTRAINT fk_cor_role_releve_cfaune_t_roles FOREIGN KEY (id_role) REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE;


ALTER TABLE ONLY cor_stade_sexe_effectif
    ADD CONSTRAINT fk_cor_stade_effectif_id_taxon FOREIGN KEY (id_occurence_cfaune) REFERENCES t_occurences_cfaune(id_occurence_cfaune) ON UPDATE CASCADE;

ALTER TABLE ONLY cor_stade_sexe_effectif
    ADD CONSTRAINT fk_cor_stade_sexe_effectif_sexe FOREIGN KEY (id_nomenclature_sexe) REFERENCES meta.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;

ALTER TABLE ONLY cor_stade_sexe_effectif
    ADD CONSTRAINT fk_cor_stade_sexe_effectif_stade_vie FOREIGN KEY (id_nomenclature_stade_vie) REFERENCES meta.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


ALTER TABLE ONLY t_releves_cfaune
    ADD CONSTRAINT fk_t_releves_cfaune_t_lots FOREIGN KEY (id_lot) REFERENCES meta.t_lots(id_lot) ON UPDATE CASCADE;

ALTER TABLE ONLY t_releves_cfaune
    ADD CONSTRAINT fk_t_releves_cfaune_technique_obs FOREIGN KEY (id_nomenclature_technique_obs) REFERENCES meta.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;

ALTER TABLE ONLY t_releves_cfaune
    ADD CONSTRAINT fk_t_releves_cfaune_eta_bio FOREIGN KEY (id_nomenclature_eta_bio) REFERENCES meta.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;

ALTER TABLE ONLY t_releves_cfaune
    ADD CONSTRAINT fk_t_releves_cfaune_t_roles FOREIGN KEY (id_numerisateur) REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE;


ALTER TABLE ONLY t_occurences_cfaune
    ADD CONSTRAINT fk_t_occurences_cfaune_t_releves_cfaune FOREIGN KEY (id_releve_cfaune) REFERENCES t_releves_cfaune(id_releve_cfaune) ON UPDATE CASCADE;

ALTER TABLE ONLY t_occurences_cfaune
    ADD CONSTRAINT fk_t_occurences_cfaune_t_roles FOREIGN KEY (id_valideur) REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE;

ALTER TABLE ONLY t_occurences_cfaune
    ADD CONSTRAINT fk_t_occurences_cfaune_taxref FOREIGN KEY (cd_nom) REFERENCES taxonomie.taxref(cd_nom) ON UPDATE CASCADE;

ALTER TABLE ONLY t_occurences_cfaune
    ADD CONSTRAINT fk_t_occurences_cfaune_meth_obs FOREIGN KEY (id_nomenclature_meth_obs) REFERENCES meta.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;

ALTER TABLE ONLY t_occurences_cfaune
    ADD CONSTRAINT fk_t_occurences_cfaune_statut_bio FOREIGN KEY (id_nomenclature_statut_bio) REFERENCES meta.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;

--------------
--CONSTRAINS--
--------------
ALTER TABLE ONLY t_occurences_cfaune
    ADD CONSTRAINT t_occurences_cfaune_cd_nom_isinbib_noms_chek CHECK (taxonomie.check_is_inbibnoms(cd_nom));

ALTER TABLE ONLY t_releves_cfaune
    ADD CONSTRAINT t_releves_cfaune_check_altitude_max CHECK (altitude_max >= altitude_min);

ALTER TABLE ONLY t_releves_cfaune
    ADD CONSTRAINT t_releves_cfaune_check_date_max CHECK (date_max >= date_min);


---------
--VIEWS--
---------
CREATE OR REPLACE VIEW contactfaune.v_techniques_observations AS(
SELECT ctn.regne,ctn.group2_inpn, n.id_nomenclature, n.mnemonique, n.libelle_nomenclature, n.definition_nomenclature, n.id_parent, n.hierarchie
FROM meta.t_nomenclatures n
LEFT JOIN taxonomie.cor_taxref_nomenclature ctn ON ctn.id_nomenclature = n.id_nomenclature
WHERE n.id_type_nomenclature = 100
AND n.id_parent != 0
);
--usage--
--SELECT * FROM contactfaune.v_techniques_observations
--WHERE group2_inpn = 'Oiseaux';
--SELECT * FROM contactfaune.v_techniques_observations
--WHERE regne = 'Plantae';


---------
--DATAS--
---------

INSERT INTO meta.t_lots  VALUES (1, 'contactfaune', 'Observation aléatoire de la faune vertébrés', 1, 2, 2, 2, 2, true, NULL, '2017-06-01 00:00:00', '2017-06-01 00:00:00');

INSERT INTO synthese.bib_modules (id_module, name_module, desc_module, entity_module_pk_field, url_module, target, picto_module, groupe_module, actif) VALUES (1, 'contact faune', 'Données issues du contact faune', 'contactfaune.t_occurences_cfaune.id_occurence_cfaune', '/cfaune', NULL, NULL, 'FAUNE', true);

INSERT INTO t_releves_cfaune VALUES(1,1,343,177,1,'2017-01-01','2017-01-01',12,'05100',5,10,'web',FALSE,NULL,NULL,'exemple test',NULL,NULL);
SELECT pg_catalog.setval('t_releves_cfaune_id_releve_cfaune_seq', 2, true);