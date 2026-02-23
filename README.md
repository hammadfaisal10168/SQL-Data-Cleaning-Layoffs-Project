# Worldwide Layoffs Data Cleaning Project (SQL)

## Project Overview
This project involves a comprehensive data cleaning process using **MySQL** on a raw dataset containing global layoff records. The goal was to transform messy data into a structured format ready for Exploratory Data Analysis (EDA).

## Key Cleaning Steps
**Duplicate Removal:** Used CTEs and Window Functions (`ROW_NUMBER`) to eliminate redundant entries.
**Standardization:** Fixed inconsistent industry names and trimmed extra spaces.
**Date Normalization:** Converted text dates into standard SQL `DATE` format.
**Missing Values:** Handled NULLs and used Self-Joins to populate missing industry data.
**Data Pruning:** Removed irrelevant columns and records with insufficient information.

## Tools Used
**Database:** MySQL / MySQL Workbench
**Key SQL Concepts:** CTEs, Joins, Window Functions, String Functions, Data Imputation.
