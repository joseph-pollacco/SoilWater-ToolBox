# =============================================================
#		module: smap2hypix
# =============================================================
module smap2hypix
   import ..path, ..tool, ..cst, ..discretization, ..path
   import DelimitedFiles, Tables, CSV

   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   #		FUNCTION : SMAP_2_HYDRO
   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   function SMAP_2_HYPIX(SoilName_2_SiteName)
      IgnoreSoil = "Rang_81a.2" #TODO remove
      
      Path_Input = "D:/Main/MODELS/SoilWater-ToolBox2/src/OUTPUT/SoilHydro/VCSNSmap/Table/VCSNSmap_Smap_Jules.csv"

      Path_Output =  path.Home * "//INPUT//DataHyPix//JULES//JulesInput//"

      println("    ~  $(Path_Input) ~")

      # Read data
         Data = DelimitedFiles.readdlm(Path_Input, ',')
      # Read header
         Header = Data[1,1:end]
      # Remove first READ_ROW_SELECT
         Data = Data[2:end,begin:end]
      # Sort data
         Data = sortslices(Data, dims=1)

      # Reading the data
         Zlayer, N  = tool.readWrite.READ_HEADER_FAST(Data, Header, "Depth_mm")
         SoilName, ~  = tool.readWrite.READ_HEADER_FAST(Data, Header, "SoilName")

        # Determening iLayer when soi changes
         iLayer_End = []
         iLayer_Start = [1]
         SoilName_Initial = SoilName[1]
         SoilName_Layer = [SoilName[1]]
         i = 1

         Nlayer = 1
         for iSoilName in SoilName
            # println(iSoilName," " ,i)

            # if soil changes
            if iSoilName ≠ SoilName_Initial
               append!(iLayer_Start, i)
               append!(iLayer_End, i-1)
               push!(SoilName_Layer, iSoilName)

               SoilName_Initial = SoilName[i] # New soil
               Nlayer += 1
            elseif  i == N
               append!(iLayer_End, i)  
            end  # if: name
            i += 1
         end # iSoilName
      
         for iLayer =1:Nlayer
            println(SoilName_Layer[iLayer], "/n")
           Zlayer_Soil = Zlayer[iLayer_Start[iLayer] : iLayer_End[iLayer]]
           Layer, Z = discretization.DISCRETISATION_AUTO(Nlayer=length(Zlayer_Soil), Zlayer=Zlayer_Soil, Zroot=800.0)

           Path = Path_Output * SoilName_2_SiteName[SoilName_Layer[iLayer]] * "//" * SoilName_2_SiteName[SoilName_Layer[iLayer]] * "_Discretisation.csv"

           println(Path)

           TABLE_DISCRETIZATION(Layer, Path, Z)
         end
      
   return
   end  # function: SMAP_2_HYDRO

   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   #		FUNCTION : TABLE
   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      function TABLE_DISCRETIZATION(Layer, Path, Z)
         Header = ["iZ";"Z";"Layer"]

         iZ = collect(1:1:length(Z))

         Output = Tables.table( [iZ Z Layer])

         CSV.write(Path, Output, header=Header)	 
      return nothing
      end  # function: TABLE



end # module smap2hypix