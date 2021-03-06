# =============================================================
#		module: readSmap
# =============================================================
module readSmap
   import ..path, ..tool, ..cst
   using Polynomials
   using DelimitedFiles
   export DATA2D, SMAP, ROCKFRAGMENT_WETTABLE_STRUCT

	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#		FUNCTION :SMAP
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      struct SMAP_STRUCT
         Depth        ::Vector{Float64}
         IsTopsoil    ::Vector{Int64}
         Soilname     ::Vector{String}
         RockFragment ::Vector{Float64}
         RockClass    ::Vector{String}
         RockDepth    ::Vector{Float64}
         MaxRootingDepth ::Vector{Float64}
      end
      function SMAP(Id_Select_True, N_SoilSelect)
         println("    ~  $(path.Smap) ~")

         # Read data
            Data = DelimitedFiles.readdlm(path.Smap, ',')
         # Read header
            Header = Data[1,1:end]
         # Remove first READ_ROW_SELECT
            Data = Data[2:end,begin:end]
         # Sort data
            Data = sortslices(Data, dims=1)
         
         IsTopsoil, ~  = tool.readWrite.READ_HEADER_FAST(Data, Header, "IsTopsoil")
         IsTopsoil = 	Int64.(IsTopsoil[Id_Select_True])

         Soilname, ~  = tool.readWrite.READ_HEADER_FAST(Data, Header, "Soilname")
         Soilname = Soilname[Id_Select_True] # Selecting the data

         RockClass, ~ = tool.readWrite.READ_HEADER_FAST(Data, Header, "RockClass")
         RockClass = RockClass[Id_Select_True] # Selecting the data

         Depth, ~  = tool.readWrite.READ_HEADER_FAST(Data, Header, "depth_mm")
         Depth = Float64.(Depth[Id_Select_True]) # Selecting the data

         RockFragment, ~ = tool.readWrite.READ_HEADER_FAST(Data, Header, "Stone_Prop")
         RockFragment = Float64.(RockFragment[Id_Select_True]) # Selecting the data

         RockDepth, ~ = tool.readWrite.READ_HEADER_FAST(Data, Header, "RockDepth_mm")
         RockDepth = Float64.(RockDepth[Id_Select_True]) # Selecting the data

         MaxRootingDepth, ~ = tool.readWrite.READ_HEADER_FAST(Data, Header, "MaxRootingDepth_mm")
         MaxRootingDepth = Float64.(MaxRootingDepth[Id_Select_True]) # Selecting the data

         smap = SMAP_STRUCT(Depth, IsTopsoil, Soilname, RockFragment, RockClass, RockDepth, MaxRootingDepth)			
      return smap
      end  # function: SMAP

      
   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   #		FUNCTION : ROCKFRAGMENT_WETTABLE
   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      struct ROCKFRAGMENT_WETTABLE_STRUCT
         # RockClass::Array{String}
         RockClass_Dict::Dict{String, Int64} 
         ??_Rf::Array{Float64} 
         ??_Rf::Array{Float64}
         N_??::Array{Int64}
         N_RockClass::Int64
         RockClass_Polynomial_Array::Array{} 
      end
      function ROCKFRAGMENT_WETTABLE()
         Path = path.SmapLookupTableWettable
         println("    ~  $(Path) ~")
         
         # Read data
            Data = DelimitedFiles.readdlm(Path, ',')
         # Read header
            Header = Data[1,1:end]
         # Remove first READ_ROW_SELECT
            Data = Data[2:end,begin:end]
         # Sort data
            # Data = sortslices(Data, dims=1, by=x->(x[1],x[2]), rev=false)

            RockClass, N_RockClass = tool.readWrite.READ_HEADER_FAST(Data, Header, "RockClass")

            RockClass_Unique = unique(RockClass)
            
            N_RockClass = length(RockClass_Unique)

            # Dictionary
            RockClass_Dict = Dict("a"=>9999)
            for i=1:N_RockClass
               RockClass_Dict[RockClass_Unique[i]] = i
            end

            ?????, N??? = tool.readWrite.READ_HEADER_FAST(Data, Header, "H[mm]")
            ?????, ~ = tool.readWrite.READ_HEADER_FAST(Data, Header, "Theta") 

            ??_Rf = zeros(Int64,(N_RockClass, 100))
            ??_Rf = zeros(Float64,(N_RockClass, 100))
            N_?? = zeros(Int64,(N_RockClass))

            iRockClass=1 ; i??=1
            for i=1:N???
               if RockClass[i] == RockClass_Unique[iRockClass]
                  ??_Rf[iRockClass,i??] = ?????[i]
                  ??_Rf[iRockClass,i??] = ?????[i]
               else
                  N_??[iRockClass]  = i?? -1
                  iRockClass += 1
                  i?? = 1
                  ??_Rf[iRockClass,i??] = ?????[i]
                  ??_Rf[iRockClass,i??] = ?????[i]
               end

               i?? += 1
            end # for i=1:N

            N_??[iRockClass]  = i?? - 1

         RockClass_Polynomial_Array = []
         for iRockClass=1:N_RockClass
            RockClass_Polynomial = Polynomials.fit(log1p.(??_Rf[iRockClass,1:N_??[iRockClass]]), ??_Rf[iRockClass,1:N_??[iRockClass]])
            X = log1p.(??_Rf[iRockClass,1:N_??[iRockClass]])

            Coeffs = coeffs(RockClass_Polynomial)
         
            RockClass_Polynomial_Array = push!(RockClass_Polynomial_Array, [Coeffs])
         end

      return rfWetable = ROCKFRAGMENT_WETTABLE_STRUCT(RockClass_Dict, ??_Rf, ??_Rf, N_??, N_RockClass, RockClass_Polynomial_Array)	
      end  # function: ROCKFRAGMENT_WETTABLE


      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      #		FUNCTION : DATA2D
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         function DATA2D(Path)
            println("    ~  $(Path) ~")

            # Read data
				   Data = DelimitedFiles.readdlm(Path, ',')
            # Read header
               Header = Data[1,1:end]
            # Remove first READ_ROW_SELECT
               Data = Data[2:end,begin:end]
            # Sort data
               Data = sortslices(Data, dims=1)

            # Read data of interest
               Id???, N_SoilSelect = tool.readWrite.READ_HEADER_FAST(Data, Header, "Id")

               Soilname???, ~ = tool.readWrite.READ_HEADER_FAST(Data, Header, "Soilname")

               ??data = []
               ??Data = []
               for iHeader in Header
                  if occursin("wrc", iHeader)
                     ?????, N_SoilSelect = tool.readWrite.READ_HEADER_FAST(Data, Header, iHeader)

                     iHeader = replace(iHeader, "wrc" => "")
                     iHeader = replace(iHeader, "kpa" => "")
                     iHeader = replace(iHeader, " " => "")
                     iHeader_Float=  parse(Float64, iHeader)

                     iHeader_Float = iHeader_Float * cst.kPa_2_Mm

                     append!(??data, iHeader_Float)

                     try
                        ??Data = hcat(??Data[1:N_SoilSelect, :], ?????[1:N_SoilSelect])
                     catch
                        ??Data = ?????[1:N_SoilSelect]
                     end
                  end # occursin("wrc", iHeader)
               end # for iHeader in Header

               ??_??????? = zeros(Float64, N_SoilSelect, length(??data))
               ??_??????? = zeros(Float64, N_SoilSelect, length(??data))
               N_??????? = zeros(Int64, N_SoilSelect)
    
               for iZ=1:N_SoilSelect
                  i??_Count = 1
                  for i??=1:length(??data)
                     if !isnan(??Data[iZ, i??])
                        ??_???????[iZ, i??_Count] = ??data[i??]
                        ??_???????[iZ, i??_Count] = ??Data[iZ, i??]
                        N_???????[iZ] += 1
                        i??_Count += 1
                     end #  !isnan(??Data[iZ, i??])
                  end # i??
               end # iZ

         return Id???, N_???????, Soilname???, ??_???????, ??_???????
         end  # function: DATA2D
   
end  # module: readSmap
# ............................................................