--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.1
-- Dumped by pg_dump version 9.6.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: example_active_record_docs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE example_active_record_docs (
    id integer NOT NULL,
    name character varying,
    icon character varying,
    enabled boolean
);


--
-- Name: example_active_record_docs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE example_active_record_docs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: example_active_record_docs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE example_active_record_docs_id_seq OWNED BY example_active_record_docs.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: example_active_record_docs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY example_active_record_docs ALTER COLUMN id SET DEFAULT nextval('example_active_record_docs_id_seq'::regclass);


--
-- Name: example_active_record_docs example_active_record_docs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY example_active_record_docs
    ADD CONSTRAINT example_active_record_docs_pkey PRIMARY KEY (id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20170801201839');

