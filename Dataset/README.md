# Dataset Engineering & Spatial Analysis

This folder contains the complete dataset engineering process performed for the LocateIQ project.

The AI recommendation model required a reliable and accurate dataset in order to generate meaningful investment recommendations.
At the beginning of the project, official geographic and demographic data was requested from **Asir Municipality**, including neighborhoods, population distribution, and public services.
Unfortunately, the requested data was not provided. Therefore, the dataset was completely built from scratch using multiple open-data sources.
# Data Sources
The dataset was created using multiple trusted sources:
### Kaggle
Dataset:
Districts and Cities Regions KSA

This dataset was used to obtain:
- Cities
- Districts
- Neighborhood names
- Latitude
- Longitude

The dataset was filtered to include only the **Asir Region**, then only **Abha** and **Khamis Mushait** neighborhoods were selected.

### OpenStreetMap (OSM)

OpenStreetMap was used as the primary geographic data source.
It provided:
- Geographic locations
- Public services
- Commercial facilities
- Infrastructure

### HOT Export Tool

The Humanitarian OpenStreetMap Export Tool was used to download Shapefile datasets.
Downloaded files included:

- Points of Interest (POI)
- Populated Places

These files were later processed in QGIS.

# Data Cleaning

After collecting the data, several preprocessing steps were performed.

These included:

- Removing duplicated columns
- Removing empty values
- Organizing attributes
- Standardizing column names
- Filtering only Asir region
- Selecting neighborhoods of Abha and Khamis Mushait
- Reviewing neighborhood names manually
- Removing duplicated neighborhoods

The cleaned data was stored in Supabase before spatial processing.

# Spatial Analysis
Spatial analysis was performed using **PostGIS**.
The first step was creating Geometry objects from latitude and longitude using:
- ST_MakePoint()
- ST_SetSRID()

This converted geographic coordinates into spatial objects that could be analyzed geographically.

## Points of Interest Analysis

The downloaded POI dataset from OpenStreetMap was imported into PostgreSQL.

Each neighborhood was analyzed against nearby POIs using:

ST_DWithin()

A search radius of **3000 meters** was used.

The following public services were counted:

- Schools
- Colleges
- Universities
- Kindergartens
- Hospitals
- Clinics
- Pharmacies
- Police Stations
- Fire Stations
- Town Halls
- Courthouses
- Places of Worship
- Museums
- Tourist Attractions

The total count was stored as:

services_count


## Competitor Analysis

Commercial activities were also analyzed within the same radius.

The following locations were counted as competitors:

- Restaurants
- Cafes
- Fast Food
- Fuel Stations
- Shops
- Hotels
- Guest Houses

The result was stored as:

competitors_count

## Population Analysis

The Populated Places dataset was imported.

Spatial analysis calculated:

- Number of populated places within 5 km
- Total nearby population
- Distance to the nearest populated place

These values were later used to estimate population density.

# Feature Engineering

After completing all spatial calculations, new features were generated for the AI model:

- Population Density
- Services Count
- Competitors Count

These features became the main inputs used by the recommendation system.

# Final Dataset

The final dataset was generated as:

LocateIQ_Dataset_Final

It contains:

- City
- Neighborhood
- Population Density
- Services Count
- Competitors Count
- Latitude
- Longitude

This dataset became the primary input for the AI recommendation model used in LocateIQ.

# Technologies Used

- Supabase
- PostgreSQL
- PostGIS
- SQL
- QGIS
- OpenStreetMap
- HOT Export Tool
- Kaggle
