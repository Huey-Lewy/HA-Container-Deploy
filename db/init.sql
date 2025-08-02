-- drop existing database
DROP DATABASE IF EXISTS ha_app;

-- create database and switch to it
CREATE DATABASE ha_app;
USE ha_app;

-- create score table and seed initial value
CREATE TABLE score (
  id    INT AUTO_INCREMENT PRIMARY KEY,
  count INT NOT NULL DEFAULT 0
);
INSERT INTO score (count) VALUES (0);

-- create pages table for HTML blobs
CREATE TABLE pages (
  name    VARCHAR(255) PRIMARY KEY,
  content MEDIUMBLOB NOT NULL
);
