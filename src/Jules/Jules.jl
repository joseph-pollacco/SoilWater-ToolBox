# =============================================================
#		module: jules joseph2
# =============================================================
module jules
   import ..path, ..option, ..tool
   import DelimitedFiles, Dates, CSV, Tables, NCDatasets, NetCDF

   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   #		FUNCTION : START_JULES
   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   function START_JULES()

      Options_θjules = "BrookCorey" # <"Texture">,<"vanGenuchten">,<"BrookCorey">

      println("    ~  $(path.JulesMetadata) ~")

      Path_Climate = "D:\\DATAraw\\JULESdata\\Climate\\VCSN_Obs\\"

      Path_θ= "D:\\DATAraw\\JULESdata\\SoilMoisture\\SoilMoisture_Site\\"

      Path_θJules= "D:\\DATAraw\\JULESdata\\SoilMoisture_Jules\\SoilMoistureJules_Site\\"

      # Read data
         Data = DelimitedFiles.readdlm(path.JulesMetadata, ',')
      # Read header
         Header = Data[1,1:end]
      # Remove first READ_ROW_SELECT
         Data = Data[2:end,begin:end]
      # Reading
         SiteName, ~   = tool.readWrite.READ_HEADER_FAST(Data, Header, "SiteName")
         VCSNgridnumber, ~ = tool.readWrite.READ_HEADER_FAST(Data, Header, "VCSNgridnumber")
         SiteNumber, ~ = tool.readWrite.READ_HEADER_FAST(Data, Header, "SiteNumber")

      # Dictionary
      # SiteName2VCSNgridnumber::Dict{String, Int64} 

         i = 1
         SiteName2VCSNgridnumber = Dict("a"=>9999) # Initializing
         SiteName2SiteNumber  = Dict("a"=>9999) # Initializi
         for iSiteName in SiteName

            # Making a new path if not exist
               Path_Output =  path.Home * "//INPUT//DataHyPix//JULES//JulesInput//" * iSiteName
               mkpath(Path_Output) 
               
            # dictionary which correspond SiteName to VCSNgridnumber
               SiteName2VCSNgridnumber[iSiteName] = VCSNgridnumber[i]
               SiteName2SiteNumber[iSiteName] = SiteNumber[i]

               i += 1

            # Reading climate
               Path_Climate_Input = Path_Climate * "VCSN_obsSM_" * string(SiteName2VCSNgridnumber[iSiteName]) * ".csv"

               Path_Climate_Output = Path_Output * "//" * iSiteName * "_Hourly_Climate.csv"
               
               READ_WRIITE_CLIMATE(Path_Climate_Input, Path_Climate_Output)
         
               # println(Path_Climate_Output)

            # Reading obs θ
               Path_θ_Input = Path_θ * "sm_obs_" * string(SiteName2SiteNumber[iSiteName]) * ".nc"

               Path_θ_Output = Path_Output * "//" * iSiteName * "_Soilmoisture.csv"

               READ_WRITE_θobs(Path_θ_Input, Path_θ_Output)

            # Reading Jules simulated θ
               Path_θjules_Input = Path_θJules * "Sta_" * string(SiteName2SiteNumber[iSiteName]) * "/"

               Path_θjules_Output =  Path_Output * "//" * iSiteName * "_Soilmoisture_Jules.csv"

               READ_WRITE_θJULES(Path_θjules_Input, Path_θjules_Output, Options_θjules)
         end

   return
   end  # function: START_JULES

   
   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   #		FUNCTION : READ_CLIMATE
   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   function READ_WRIITE_CLIMATE(Path_Input, Path_Output)

      # Read data
         Data = DelimitedFiles.readdlm(Path_Input, ',')
      # Read header
         Header = Data[1,1:end]
      # Remove first READ_ROW_SELECT
         Data = Data[2:end,begin:end]
      # Reading
         Date, N = tool.readWrite.READ_HEADER_FAST(Data, Header, "OBS_DATE")
         Rain, ~ = tool.readWrite.READ_HEADER_FAST(Data, Header, "rain_fill")
         Pet, ~ = tool.readWrite.READ_HEADER_FAST(Data, Header, "pet_fao56")

         Year  = Dates.year.(Dates.DateTime.(Date))
         Month = Dates.month.(Dates.DateTime.(Date))
         Day   = Dates.day.(Dates.DateTime.(Date))
         Hour  = fill(9::Int64, N)
         Minute = fill(0::Int64, N)
         Second = fill(0::Int64, N)
         
         Header = ["Year";"Month";"Day";"Hour";"Minute";"Second";"PET(mm)";"Rain(mm)"]

         Output = Tables.table( [Year Month Day Hour Minute Second Pet Rain])

         CSV.write(Path_Output, Output, header=Header)	
         
      return nothing
      end  # function: READ_CLIMATE


   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   #		FUNCTION : READ_WRITE_θobs
   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      function READ_WRITE_θobs(Path_θ_Input, Path_θ_Output)

         Months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

         # Getting θ observed
          θdata = Float64.(NetCDF.open(Path_θ_Input, "obsm"))

          N = length(θdata)

         #  for i=1:N
         #    if θdata[i] == -999
         #       θdata[i] = NaN
         #    end
         #  end

         # Getting the inititilal starting date in the format 1 January 2008   
            Data = NetCDF.open(Path_θ_Input)

            Data2 = NCDatasets.Dataset(Path_θ_Input)

            Start_Date = Data2[ "obsm"].attrib["initial_date"]

            # Converting to Year Month Day
               # day
                  First_Space = findfirst(" ", Start_Date)
      
                  Day = Start_Date[1:First_Space[1]]
                  Start_Date = replace(Start_Date, Day => "")
                  Day = parse(Int, Day)

               # Month
                  Month = 0
                  for iMonth = 1:12
                     if occursin(Months[iMonth],Start_Date)
                        Month = iMonth
                        Start_Date = replace(Start_Date, Months[iMonth] => "")
                        break
                     end
                  end

               # Year
                  Year = parse(Int, Start_Date)

               # Date
                  Start_Date = Dates.Date(Year,Month,Day)

                # Need to get dates by adding 1 day
                  Years = Array{Int64}(undef, N)
                  Months = Array{Int64}(undef, N)
                  Days = Array{Int64}(undef, N)
                  Hours  = fill(9::Int64, N)
                  Minutes = fill(0::Int64, N)
                  Seconds = fill(0::Int64, N)
                  for iDay = 1:N
                     Add_Date     = Start_Date + Dates.Day(iDay)

                     Years[iDay]  = Dates.year(Add_Date)
                     Months[iDay] = Dates.month(Add_Date)
                     Days[iDay]   = Dates.day(Add_Date)
                  end

            # Writing to file
               Header = ["Year";"Month";"Day";"Hour";"Minute";"Second";"Z=200mm"]

               Output = Tables.table( [Years Months Days Hours Minutes Seconds θdata])
         
               CSV.write(Path_θ_Output, Output, header=Header)	   

      return nothing
      end  # function: READ_WRITE_θobs



   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   #		FUNCTION : READ_WRITE_θobs
   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   """
   # Four nc files are saved at each station directory:
   loobos.p2.01d_CP.nc  loobos.p2.01d.nc  loobos.p2.01d_type.nc

   Option" Texture":       loobos.p2.01d_type.nc is the simulation using soil type data from Landcare and Table 2 of Chen and Dudhia (2001) and Brook and Corey model.
   Option" vanGenuchten":  loobos.p2.01d.nc is the simulation using van Genuchten model and the updated soil parameters from Landcare
   Option "BrookCorey":    loobos.p2.01d_CP.nc is the simulation using Brook and Corey model and updated the soil parameters from Landcare.

   For the 4th nc file saved in each station dir such as: sm_sim_obs_11234.nc. It is the daily soil moisture observations and daily soil moisture simulations by JULES using our soil data at Station 11234. Please ignore this simulation for all stations. e.g., sm_sim_obs_11234.nc is for station 11234.

   """
      function READ_WRITE_θJULES(Path_θjules_Input, Path_θjules_Output, Options_θjules)

         OptionsJules = ["Texture","vanGenuchten","BrookCorey"]

         OptionsFile =["loobos.p2.01d_type.nc", "loobos.p2.01d.nc", "loobos.p2.01d_CP.nc"]

         Months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

         # Initializing the dictionary
         i = 1
         OptionsJules_2_OptionsFile = Dict("a"=>"9999") # Initializing
         for iOptionJules in OptionsJules
            OptionsJules_2_OptionsFile[iOptionJules] = OptionsFile[i]
            i += 1
         end

         # Getting θ observed
         Path_θjules = Path_θjules_Input * OptionsJules_2_OptionsFile[Options_θjules]


         println(NCDatasets.Dataset(Path_θjules))


         θdata = Float64.(NetCDF.open(Path_θjules, "obsm"))

         N = length(θdata)
      
         # Getting the inititilal starting date in the format 1 January 2008   
            Data = NetCDF.open(Path_θjules)

            Data2 = NCDatasets.Dataset(Path_θjules)

            Start_Date = Data2[ "obsm"].attrib["initial_date"]

            # Converting to Year Month Day
               # day
                  First_Space = findfirst(" ", Start_Date)
      
                  Day = Start_Date[1:First_Space[1]]
                  Start_Date = replace(Start_Date, Day => "")
                  Day = parse(Int, Day)

               # Month
                  Month = 0
                  for iMonth = 1:12
                     if occursin(Months[iMonth],Start_Date)
                        Month = iMonth
                        Start_Date = replace(Start_Date, Months[iMonth] => "")
                        break
                     end
                  end

               # Year
                  Year = parse(Int, Start_Date)

               # Date
                  Start_Date = Dates.Date(Year,Month,Day)

               # Need to get dates by adding 1 day
                  Years = Array{Int64}(undef, N)
                  Months = Array{Int64}(undef, N)
                  Days = Array{Int64}(undef, N)
                  Hours  = fill(9::Int64, N)
                  Minutes = fill(0::Int64, N)
                  Seconds = fill(0::Int64, N)
                  for iDay = 1:N
                     Add_Date     = Start_Date + Dates.Day(iDay)

                     Years[iDay]  = Dates.year(Add_Date)
                     Months[iDay] = Dates.month(Add_Date)
                     Days[iDay]   = Dates.day(Add_Date)
                  end

            # Writing to file
               Header = ["Year";"Month";"Day";"Hour";"Minute";"Second";"Z=200mm"]

               Output = Tables.table( [Years Months Days Hours Minutes Seconds θdata])
         
               CSV.write(Path_θjules_Output, Output, header=Header)	   

      return nothing
      end  # function: READ_WRITE_θobs
      
      
   end  # module: jules
# ............................................................