#%%
import rioxarray

%matplotlib inline

#%%
# from https://openaerialmap.org/
cog_url = (
    "https://oin-hotosm.s3.amazonaws.com/"
    "5d7dad0becaf880008a9bc88/0/5d7dad0becaf880008a9bc89.tif"
)

#%%
rds = rioxarray.open_rasterio(cog_url, masked=True, overview_level=4)
rds

#%%
rds.astype("int").plot.imshow(rgb="band")

