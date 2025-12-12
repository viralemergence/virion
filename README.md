# Data
We highly recommend using the [R](https://github.com/viralemergence/virionData) or [python](https://pypi.org/project/py-virion-data/) packages for accessing the data. 
Data can be found here: [https://doi.org/10.5281/zenodo.15643003](https://doi.org/10.5281/zenodo.15643003). 

# Package for accessing data
An R package for accessing the data can be found here: [https://github.com/viralemergence/virionData](https://github.com/viralemergence/virionData)  
A python library for accessing the data can be found here: [https://pypi.org/project/py-virion-data/](https://pypi.org/project/py-virion-data/)


# Citation

If you use VIRION for your research, please:

-    Cite the publication: Carlson CJ, Gibb RJ, Albery GF, Brierley L, Connor R, Dallas T, Eskew EA, Fagre AC, Farrell MJ, Frank HK, Muylaert RL, Poisot T, Rasmussen AL, Ryan SJ, Seifert SN. The Global Virome in One Network (VIRION): an Atlas of Vertebrate-Virus Associations. mBio. 2022 Mar 1. DOI: 10.1128/mbio.02985-21.
-    Cite the version of the data you used. In R `virionData::get_citation(zenodo_id = "ZENODO_ID_FOR_VERSION", style = "apa")`. In python `deposit.get_citation(style = "apa",zenodo_id = "ZENODO_ID_FOR_VERSION")`.
-    Include the following statement in your acknowledgements: "This project was supported by the Verena data ecosystem, funded by the U.S. National Science Foundation (NSF DBI 2213854)."

If necessary (e.g., for specific journal requirements), you can also cite the VIRION codebase itself using this DOI: https://doi.org/10.5281/zenodo.15643003.
