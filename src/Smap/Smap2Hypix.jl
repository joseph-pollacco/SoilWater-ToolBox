# =============================================================
#		module: smap2hypix
# =============================================================
module smap2hypix
   import ..path, ..tool, ..cst, ..discretization, ..path, ..hydroStruct, ..reading, ..vegStruct
   import DelimitedFiles, Tables, CSV

   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   #		FUNCTION : SMAP_2_HYDRO
   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   function SMAP_2_HYPIX(SoilName_2_SiteName)
      IgnoreSoil = "Rang_81a.2" #TODO remove

      Path_Input ="D:\\DATAraw\\JULESdata\\HydraulicParam\\Jules_HydroParam_Kosugi.csv"

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
         ZrootDepth_Max, ~= tool.readWrite.READ_HEADER_FAST(Data, Header, "MaxRootingDepth_mm")

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
            
            # Abstracting layers per soil =====
               Zlayer_Soil = Zlayer[iLayer_Start[iLayer] : iLayer_End[iLayer]]
               Path = Path_Output * SoilName_2_SiteName[SoilName_Layer[iLayer]] * "//" * SoilName_2_SiteName[SoilName_Layer[iLayer]] * "_Layer.csv"
               Layer = collect(1:1:length( Zlayer_Soil))
               TABLE_DISCRETIZATION(Layer, Path, Zlayer_Soil)      

            # Automatic Disscretizing of layers per soil =====
               Layer, Z = discretization.DISCRETISATION_AUTO(Nlayer=length(Zlayer_Soil), Zlayer=Zlayer_Soil, Zroot=800.0)
               Path = Path_Output * SoilName_2_SiteName[SoilName_Layer[iLayer]] * "//" * SoilName_2_SiteName[SoilName_Layer[iLayer]] * "_Discretisation.csv"
               TABLE_DISCRETIZATION(Layer, Path, Z)

            # Smap_Hydro Hydraulic parameters of layers per soil ====
               hydroSmap = hydroStruct.HYDROSTRUCT(N) # Making a structure

               # Abstracting data
               hydroSmap, N_SoilSelect =  reading.READFILE(hydroSmap, Path_Input; iStart=iLayer_Start[iLayer], iEnd=iLayer_End[iLayer])

               Path = Path_Output * SoilName_2_SiteName[SoilName_Layer[iLayer]] * "//" * SoilName_2_SiteName[SoilName_Layer[iLayer]] * "_HypixHydro.csv"

               N_iLayers = iLayer_End[iLayer] - iLayer_Start[iLayer] + 1

               TABLE_HYDRO_VEG(hydroSmap, N_iLayers, Path)

            # Vegetation parameters per soil ====
                  vegSmap = vegStruct.VEGSTRUCT()

               # Abstracting data
               Path_Vegetaion ="D:\\DATAraw\\JULESdata\\Vegetation\\Vegetation.csv"

               vegSmap.Zroot = min(vegSmap.Zroot, ZrootDepth_Max[1])

               vegSmap, N_SoilSelect = reading.READFILE(vegSmap, Path_Vegetaion; iStart=1, iEnd=1)

                Path = Path_Output * SoilName_2_SiteName[SoilName_Layer[iLayer]] * "//" * SoilName_2_SiteName[SoilName_Layer[iLayer]] * "_Vegetation.csv"

                TABLE_HYDRO_VEG(vegSmap, 1, Path)
         end
      
   return nothing
   end  # function: SMAP_2_HYDRO

   
   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   #		FUNCTION : TABLE_DISCRETIZATION
   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      function TABLE_DISCRETIZATION(Layer, Path, Z)
         Header = ["iZ";"Z";"Layer"]

         iZ = collect(1:1:length(Z))

         Output = Tables.table( [iZ Z Layer])

         CSV.write(Path, Output, header=Header)	 
      return nothing
      end  # function: TABLE


   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#		FUNCTION : TABLE_DISCRETIZATION
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		function TABLE_HYDRO_VEG(hydroSmap, N_iLayers, Path)
			println("			~ $(Path) ~")

			Id = 1:1:N_iLayers

			Matrix, FieldName_String = tool.readWrite.STRUCT_2_FIELDNAME(N_iLayers, hydroSmap)
					
			pushfirst!(FieldName_String, string("iLayer")) # Write the "Id" at the very begenning

			open(Path, "w") do io
				DelimitedFiles.write(io, [0xef,0xbb,0xbf])  # To reading utf-8 encoding in excel
				DelimitedFiles.writedlm(io,[FieldName_String] , ",",) # Header
				DelimitedFiles.writedlm(io, [Int64.(Id) Matrix], ",")
			end # open
      return nothing
		end  # function: TABLE_HYDRO

end # module smap2hypix