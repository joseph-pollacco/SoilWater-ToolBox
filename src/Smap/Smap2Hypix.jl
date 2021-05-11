# =============================================================
#		module: smap2hydro
# =============================================================
module smap2hydro
   import ..path, ..tool, ..cst
   import DelimitedFiles

   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   #		FUNCTION : SMAP_2_HYDRO
   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   function SMAP_2_HYDRO()
      
      Path_Input = "D:/Main\MODELS/SoilWater-ToolBox2/src/OUTPUT/SoilHydro/VCSNSmap/Table/VCSNSmap_Smap.csv"

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
         Z_LayerDown, N  = tool.readWrite.READ_HEADER_FAST(Data, Header, "Depth_mm")

         Z_LayerUp = Z_LayerDown[1:N-1]
         prepend!(Z_LayerUp,0)

         SoilName, ~  = tool.readWrite.READ_HEADER_FAST(Data, Header, "SoilName")

         LayerDown = fill(0.0:Float64, N, 8)
         LayerUp =fill(0.0:Float64, N, 8)
         iSoil = 1
         SoilName_Initial = SoilName[1]
         i = 1
         for iSoilName in SoilName

            # Same soil profile
            if iSoilName == SoilName_Initial
              append!(LayerDown, Z_LayerDown[i])

              append!(LayerDown, Z_LayerUp[i])
            # Different Soil profile
            else
               LayerDown = []
               LayerUp = []   
                SoilName_Initial = iSoilName
                append!(LayerDown, Z_LayerDown[i])
                append!(LayerDown, Z_LayerUp[i])
            end  # if: name

            i += 1
            
         end
   return
   end  # function: SMAP_2_HYDRO


   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   #		FUNCTION : name
   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   function name()
      
      return
   end  # function: name
   
end  # module smap2hydro
# ............................................................