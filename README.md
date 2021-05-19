# SoilWater-ToolBox

**The package was developped by Joseph Pollacco and Jesús Fernández Gálvez**

The HyPix model is open source under the **GP-3.0** License. This software is part of a set of interlinked modules implemented into the SoilWater-ToolBox ecosystem led by J.A.P Pollacco from Manaaki Whenua – Landcare Research in New-Zealand and J. Fernández-Gálvez from the University of Granada in Spain. The preliminary objectives of the SoilWater-ToolBox are to derive the soil hydraulic parameters by using a wide range of cost-effective methods. The estimated hydraulic parameters can be directly implemented into HyPix to compute the soil water budget. The SoilWater-ToolBox enables to perform inter comparison and sensitivity analyses of the hydraulic parameters computed from different methods on the soil water fluxes. To date, the following modules are currently included into the SoilWater-ToolBox:

1. Intergranular Mixing Particle size distribution model: derives unimodal hydraulic parameters by using particle size distribution (Pollacco et al., 2020);
2. General Beerkan Estimation of Soil Transfer parameters method: derives the unimodal hydraulic parameters from single ring infiltration experiments (Fernández-Gálvez et al., 2019);
3. Sorptivity model: novel computation of sorptivity used in the General Beerkan Estimation of Soil Transfer parameters method (Lassabatere et al., 2021);
4. Derive saturated hydraulic conductivity from unimodal and bimodal θ(ψ) (Pollacco et al., 2017, 2013b);
5. Invert hydraulic parameters from θ time series;
6. Derive unique and physical bimodal Kosugi hydraulic parameters from inverse modelling (Fernández-Gálvez et al., 2021) using water retention and/or unsaturated hydraulic conductivity data directly measured in the laboratory or indirectly obtained from inverting θ time series. 



<!-- 


This code base is using the Julia Language and [DrWatson](https://juliadynamics.github.io/DrWatson.jl/stable/)
to make a reproducible scientific project named
> SoilWater-ToolBox

It is authored by Datseris.

To (locally) reproduce this project, do the following:

0. Download this code base. Notice that raw data are typically not included in the
   git-history and may need to be downloaded independently.
1. Open a Julia console and do:
   ```
   julia> using Pkg
   julia> Pkg.activate("path/to/this/project")
   julia> Pkg.instantiate()
   ```

This will install all necessary packages for you to be able to run the scripts and
everything should work out of the box. -->
