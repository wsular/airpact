"""
Python module for handling AIRPACT model data from Washington State University. 
This modeling project is led by Dr. Joe Vaughan at WSU's Laboratory for 
Atmospheric Research.

Usage:
    # ....Determine grid cell indices for specific location
    import airpact
    i, j = airpact.get_WRF_indices(+42.7298, -117.1817)   # for Pullman, WA
    
    # ....Export PM2.5 gridded output to a geoJSON file.
    import airpact as ap
    airpact = ap.AIRPACT()
    airpact.to_geojson('WSU_LAR_AIRPACT-PM2_5.geojson')

File dependenices:
    This Python module must be stored in the same directory as
        GRIDCRO2D    - Geographic informatin for AIRPACT5 model results
        zipcodes.txt - US zipcodes; used to determine lat/lon

Written by Von P. Walden, Washington State University
           Created: 18 June 2020 
           Updated: 16 Oct 2020 - Changed to smokeCARE (vpw)
           Updated: 24 Mar 2021 - Slight improvements to documentation (vpw)

"""

import numpy as np
import xarray as xr
import pandas as pd
import geopandas as gpd
import requests

class Data:

    def __init__(self):
        ##################################### Initializations ########################################
        # ....Loads the latitudes and longitudes for the AIRPACT data.
        grid = xr.open_dataset('GRIDCRO2D')
        self.lats = np.reshape(grid.LAT.values,(258,285))
        self.lons = np.reshape(grid.LON.values,(258,285))

        # ....Determine the indices into the AIRPACT forecast for the zipcode
        self.zipcodes   = np.loadtxt('zipcodes.txt').reshape((258,285)).astype(int)
        
        return

    def find_WRF_indices(self, lat, lon):
        # Read latitude and longitude from file into numpy arrays
        # Renamed findWRFpixel from original function, naive_fast, written by Vikram Ravi.
        dist_sq = (self.lats-lat)**2 + (self.lons-lon)**2
        minindex_flattened = dist_sq.argmin()  # 1D index of min element
        iy_min, ix_min = np.unravel_index(minindex_flattened, self.lats.shape)

        return int(iy_min),int(ix_min)
    
    def readPM25(self):
        # ....Nearest date
        self.date   = pd.to_datetime('now', utc=True)
        if ((self.date.hour>=0) and (self.date.hour<15)):      # Avoids hours when AIRPACT5 is running for new day
            self.date = self.date - pd.Timedelta(days=2)
        self.year  = str(self.date.year)
        self.month = str(self.date.month).zfill(2)
        self.day   = str(self.date.day).zfill(2)

        # ....Download PM2.5 forecast from AIRPACT5 for desire date.
        webAddress = 'http://lar.wsu.edu/airpact/airraid/' + self.year + '/' + 'PM25_24hr_' + self.year + self.month + self.day + '.json'
        try:
            data    = pd.read_json('[' + requests.get(webAddress).content.decode('utf-8')[:-2] + ']')
        except:
            raise TypeError('AIRPACT5 forecasting data for ' + self.date.strftime('%Y-%m-%d') + ' is currently unavailable... Contact Joe Vaughan (jvaughan@wsu.edu) or try again later...')
        r = data.ROW.values.max()
        c = data.COL.values.max()
        pm25 = data.RollingA24_PM25.values.reshape(c,r).T
        
        return pm25

    def to_geojson(self, filename):
        """
        Function to save AIRPACT PM 2.5 data as a GeoJSON file

        Input:
            filename - name of GeoJSON file to save AIRPACT data to

        Output:
            GeoJSON file stored to disk

        Von P. Walden, Washington State University
        18 Jun 2020
        """
        # ....Creates a GeoJSON version of the AIRPACT data.
        df = pd.DataFrame({'PM2.5': self.pm25.flatten(), 'latitude': self.lats.flatten(), 'longitude': self.lons.flatten()})
        self.GeoJSON = gpd.GeoDataFrame(df['PM2.5'], geometry=gpd.points_from_xy(df.longitude, df.latitude))

        self.GeoJSON.to_file(filename, driver='GeoJSON')

        return

    def retrieveBoundingBox(lon, lat, dlon, dlat):
        """
        Function to retrieve AIRPACT PM 2.5 data from a previously
        generated GeoJSON file, according to a bounding box.
    
        Definition of bounding box:
            lon  - central longitude (in degrees) of bounding box
                        (- values are West longitudes, + are East longitudes)
            lat  - central latitude (in degress) of bounding box
            dlon - +/- delta longitude about central longitude, 
                    used to determine width of bounding box
            dlat - +/- delta latitude about central longitude, 
                    used to determine height of bounding box
        
        Example usage:
            import airpact as ap
            bb = ap.retrieveBoundingBox(-117.4260, 47.6588, 0.5, 0.5)
        
        Von P. Walden, Washington State University
        18 Jun 2020
    
        """
        # ....Assumes that this GeoJSON file exists (as AWS S3 bucket...)
        gdf = gpd.read_file('WSU_LAR_AIRPACT-PM2_5.geojson')
        
        # ....Provides simple error checking on limits of bounding box.
        bound_limits = gdf.total_bounds
        if ((lon-dlon<bound_limits[0]) or (lon+dlon>bound_limits[2]) or (lat-dlat<bound_limits[1]) or (lat+dlat>bound_limits[3]) ):
            return TypeError('Definition of the bounding box is beyond the limits of the GeoJSON data file!')
        else:
            # ....Returns a subset of the GeoJSON data based on the bounding box
            #       defined by [lon-dlon:lon+dlon, lat-dlat:lat+dlat]
            return gdf.cx[lon-dlon:lon+dlon, lat-dlat:lat+dlat]
