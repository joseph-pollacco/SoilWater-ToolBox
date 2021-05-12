# =============================================================
#		module: smap2hypix
# =============================================================
module smap2hypix
   import ..path, ..tool, ..cst, ..discretization
   import DelimitedFiles

   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   #		FUNCTION : SMAP_2_HYDRO
   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   function SMAP_2_HYPIX()
      IgnoreSoil = "Rang_81a.2" #TODO remove
      
      Path_Input = "D:/Main/MODELS/SoilWater-ToolBox2/src/OUTPUT/SoilHydro/VCSNSmap/Table/VCSNSmap_Smap _Jules.csv"

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
           @show  Zlayer_Soil

           Layer, Z = discretization.DISCRETISATION_AUTO(Nlayer=length(Zlayer_Soil), Zlayer=Zlayer_Soil, Zroot=800.0)
           @show Z
           @show Layer
         end
      
   return
   end  # function: SMAP_2_HYDRO

   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   #		FUNCTION : TABLE
 
   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   function TABLE()
      Header = ["Year";"Month";"Day";"Hour";"Minute";"Second";"PET(mm)";"Rain(mm)"]

      Output = Tables.table( [iZ Z Day Hour Minute Second Pet Rain])

      CSV.write(Path_Output, Output, header=Header)	 
      return
   end  # function: TABLE



end # module smap2hypix