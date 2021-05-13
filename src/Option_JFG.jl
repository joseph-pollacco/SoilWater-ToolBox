# =============================================================
#		MODULE: global options
# ===========================================================
module option

	mutable struct INFILT
		DataSingleDoubleRing  
		OptimizeRun  
		Model                	
      SortivityVersion     
		SorptivitySplitModel  
		SorptivityModel      
		HydroModel       
      θsOpt            
      θrOpt            
      σ_2_Ψm          
   	KunsatΨ         
      KsOpt 
		Kunsat_JustRun 
		Plot_Sorptivity        	
		Plot_SeIni_Range       
		Plot_∑Infilt           
		Plot_θΨ                
		Plot_Sorptivity_SeIni  
		bestFunc # it is a structure
	end

	mutable struct BESTFUNC
		Continous
	end

	mutable struct DATA
		data
	end

	mutable struct ROCKFRAGMENT
		rockFragment
		RockInjected
		RockWettable
	end

	mutable struct SMAP
		CorrectStone
		CorrectStoneWetability
		UsePointKosugiBimodal
		CombineData
		Plot_Kunsat
	end

	mutable struct HYDRO
		HydroModel
		θrOpt
		σ_2_Ψm
		θs_MinFromData
		Ks_MinMaxFromData
		KunsatΨ
		KsOpt
		Kunsat_JustRun
		Plot_θΨ
		Plot_σ_Ψm
	end

	mutable struct PSD
		Model
		OptimizePsd
		Psd_2_θr
		∑Psd_2_ξ1
		HydroParam
		HydroModel
		θsOpt
		θrOpt
		σ_2_Ψm
		KunsatΨ
		KsOpt
		Kunsat_JustRun
		Plot_Psd_θΨ
		Plot_θr
		Plot_IMP_Model
		Table_Psd_θΨ_θ
	end
 
	mutable struct HYPIX
		ClimateDataTimestep
		RainfallInterception
		Evaporation
		RootWaterUptake
		RootWaterUptakeComp
		LookupTable_Lai
		LookUpTable_CropCoeficient
		θΨKmodel
		BottomBoundary
		∂R∂Ψ_Numerical
		AdaptiveTimeStep
		NormMin
		Flag_ReRun
		Qbottom_Correction
		Lai_2_SintMax
		σ_2_Ψm
		σ_2_θr
		θs_Opt
		calibr
		θobs_Hourly
		Signature_Run
		Table
		Table_Discretization
		Table_Q
		Table_RootWaterUptake
		Table_TimeSeries
		Table_Ψ
		Table_θ
		Table_TimeSeriesDaily
		Tabule_θΨ
		Table_Climate
		Plot_Vegetation
		Plot_θΨK
		Plot_Interception
		Plot_Other
		Plot_Sorptivity
		Plot_Hypix
		Plot_Climate
		Plot_θ
		Plot_Ψ
		Plot_Flux
		Plot_WaterBalance
		Plot_ΔT
	end

	mutable struct GLOBALOPT
		HydroTranslateModel
		Hypix
		Smap
		AddPointKosugiBimodal
		BulkDensity
		θΨ
		Psd
		Infilt
		Temporary
		Jules
		DownloadPackage
		Plot
		Plot_Show
	end

	mutable struct OPTION
		infilt 
		rockfragment
		smap
		hydro
		psd
		hypix
		globalopt
	end	

		
	# =============================================================
	#		data options
	# ===========================================================
		psd = true # <true> Particle size data is available; <false> Particle size data is not available
			
		data = DATA(psd)

	# =============================================================
	#	   rock fragment options
	# =============================================================
		RockFragment = true # <true> make correction for rock fragment; <false> no correction for rock fragment
		RockInjected = true # <true> rocks are injected in to the fine soils; <false> rocks are included in the bulk BulkDensity_Infilt
		RockWettable = false # <true> rocks are wettable; <false> 

		rockfragment = ROCKFRAGMENT(RockFragment, RockInjected, RockWettable)
		
	# =============================================================
	#		smap options
	# =============================================================
			CorrectStone = true # <true> or <false>
			CorrectStoneWetability = true # <true> or <false>
			UsePointKosugiBimodal = true # <true> or <false>
			CombineData = true
			Plot_Kunsat = false  # <true> or <false>

			smap = SMAP(CorrectStone, CorrectStoneWetability, UsePointKosugiBimodal, CombineData, Plot_Kunsat)

	# =============================================================
	#		hydro options
	# =============================================================
		# HYDRAULIC MODEL
        HydroModel      = :Kosugi # <:Kosugi>*; <:Vangenuchten>; <:BrooksCorey>; <:ClappHornberger>; <:VangenuchtenJules>
        θrOpt           = :Opt # <:Opt> optimises; <:ParamPsd> derive from PSD and uses α1 and α1 from parameters in Param.jl; <:σ_2_θr>	
     	  σ_2_Ψm          = :Constrained # <:Constrained> Ψm physical feasible range is computed from σ <:UniqueRelationship> Ψm is computed from σ; <:No> optimisation of σ & Ψm with no constraints

		  # Min & Max from data
			θs_MinFromData = false # <false> feasible range from GUI, <true> feasible range derive from data
			Ks_MinMaxFromData = false # <false> feasible range from GUI, <true> feasible range derive from data
				
		  # HAVE WE Kunsat(ψ)DATA
         KunsatΨ         = true #  <true>* Optimize hydraulic parameters from θ(Ψ) & K(Ψ); <false>
				KsOpt = :Opt # <:Opt> Optimize Ks (require KunsatΨ=true); <:Data> derived from Max K(Ψ)
				Kunsat_JustRun = false

			# PLOTTING
			 Plot_θΨ = true
			 Plot_σ_Ψm = false
			
		hydro = HYDRO(HydroModel, θrOpt, σ_2_Ψm, θs_MinFromData, Ks_MinMaxFromData, KunsatΨ, KsOpt, Kunsat_JustRun, Plot_θΨ, Plot_σ_Ψm)

	# =============================================================
	#		psd options     
	# =============================================================
		Model       = :IMP # <:IMP>* Intergranular Mixing Model; <:Chang2019Model>
		OptimizePsd = :Run # <:OptSingleSoil>; <:OptAllSoil>; or <:Run>
		Psd_2_θr    = :ParamPsd # <:Opt> optimises parameters α1 and α1; <:ParamPsd> uses α1 and α1 from parameters in Param.jl 

		# FOR OPTIMIZEPSD = :Single
			∑Psd_2_ξ1 = true  # optimize ξ1
			
		# FITTING THE PSD FUNCTION TO A HYDRAULIC MODEL			
			HydroParam  = true # <true> Optimize the hydraulic parameters from θ(Ψ)psd OR <false>
			HydroModel      = :Kosugi 		# <:Kosugi>*; <:Vangenuchten>; <:BrooksCorey>; <:ClappHornberger>
			θsOpt           = :Φ #  <:Opt> Optimize θs; <:Φ> derived from total porosity which requires some correction from param.hydro.Coeff_Φ_2_θs;
			θrOpt           = :ParamPsd # <:Opt> optimises; <:ParamPsd> derive from PSD and uses α1 and α1 from parameters in Param.jl; <:σ_2_θr>
			σ_2_Ψm          = :Constrained # <:Constrained> Ψm physical feasible range is computed from σ  <:No> optimisation of σ & Ψm with no constraints
			KunsatΨ         = false #  <true>* Optimize hydraulic parameters from θ(Ψ) & K(Ψ); <false>
				KsOpt = :Opt # <:Opt> Optimize Ks (require KunsatΨ=true); <:Data> derived from Max K(Ψ)
				Kunsat_JustRun = false

			# PLOTTING
            Plot_Psd_θΨ    = true # <true>  plot θΨ of PSD; <false>
            Plot_θr        = true #  <true>  plot θr data and model from Psd ; <false>	
				Plot_IMP_Model = true # <true> ; plot IMP model results for publication; <false>
				
			# TABLE
				Table_Psd_θΨ_θ = true # <true> derive θ values at prescribed Ψ
							
			# if OptimizePsd == :Single 
			# 	const SubclayOpt = false # Determine if optimize an additional fraction < 2 μm clay content or if fixed deriving from a constant value param.Subclay
			# else
			# 	const SubclayOpt = true # Determine if optimize an additional fraction < 2 μm clay content or if fixed deriving from a constant value param.Subclay
			# end			
	
			psd = PSD(Model, OptimizePsd, Psd_2_θr, ∑Psd_2_ξ1, HydroParam, HydroModel, θsOpt, θrOpt, σ_2_Ψm, KunsatΨ, KsOpt, Kunsat_JustRun, Plot_Psd_θΨ, Plot_θr, Plot_IMP_Model, Table_Psd_θΨ_θ)

	# =============================================================
	#		infiltration options
	# =============================================================
		# MODEL
      DataSingleDoubleRing = :Single	# <:Double> infiltration measured by double ring infiltrometer; <:Single> infiltration measured by single ring infiltrometer
      OptimizeRun          = :Opt # <:Opt>* Optimise hydraulic parameters from infiltration data; <:Run> run inftration curves from known hydraulic parameters; <:RunOptKs>  run inftration curves from known hydraulic parameters but optimize Ks only
      Model                = :QuasiExact 	# <:QuasiExact> physical approach; <:Best_Univ> statistical improved approach
      SortivityVersion     = :NonInfinity # <:NonInfinity> improved method; <:Traditional> old method with problems of infinity
      SorptivitySplitModel = :Split # <:Split>; <:Split_η>
      SorptivityModel      = :Parlange # <:Parlange> strong non-linear diffusivity;  <:Crank> constant diffusivity; <:Philip_Knight> dirac delta-function diffusivity; <:Brutsaert> moderate non-linear diffusivity,
		# DERIVING HYDRAULIC PARAMETERS FROM INFILTRATION TESTS
		  HydroModel      = :Kosugi # <:Kosugi>*; <:Vangenuchten>; <:BrooksCorey>; <:ClappHornberger>
		  θsOpt           = :Φ #  <:Opt> Optimize θs; <:Φ> derived from total porosity which requires some correction from param.hydro.Coeff_Φ_2_θs;
		  θrOpt           = :Opt # <:Opt> optimises; <:ParamPsd> derive from PSD and uses α1 and α1 from parameters in Param.jl; <:σ_2_θr>		
		  σ_2_Ψm          = :Constrained # <:Constrained> Ψm physical feasible range is computed from σ <:UniqueRelationship> Ψm is computed from σ; <:No> optimisation of σ & Ψm with no constraints
		  KunsatΨ         = true #  <true>* Optimize hydraulic parameters from θ(Ψ) & K(Ψ); <false>
			  KsOpt = :Opt # <:Opt> Optimize Ks (require KunsatΨ=true); <:Data> derived from Max K(Ψ)
			  Kunsat_JustRun = false
	
		# PLOTTING
         Plot_Sorptivity       = true # <true> or <false>	
         Plot_SeIni_Range      = true # <true> computes infiltration curves for different SeIn set in param.infilt.SeIni_Output <false> no outputs
         Plot_∑Infilt          = true # <true> plots cumulative infiltration curves for experimental and derived data <false> no plots
         Plot_θΨ               = true # <true>; <false>
         Plot_Sorptivity_SeIni = true # <true> computes sorptivity curves as a function of Se <false> no outputs

		# =============================================================
		#		besUniv options
		# ==========================================================
			Continous = true # <true> this is the continous form derived by Joseph <false> Traditional non continous
			
		bestFunc = BESTFUNC(Continous) 

		infilt = INFILT(DataSingleDoubleRing, OptimizeRun, Model, SortivityVersion, SorptivitySplitModel, SorptivityModel, HydroModel, θsOpt, θrOpt, σ_2_Ψm, KunsatΨ, KsOpt, Kunsat_JustRun, Plot_Sorptivity, Plot_SeIni_Range, Plot_∑Infilt, Plot_θΨ, Plot_Sorptivity_SeIni, bestFunc)

	# =============================================================
	#		hypix options
	# =============================================================
		# DATA
			ClimateDataTimestep = "Daily" # <Hourly>; <Daily>

		# MODULES USED
         RainfallInterception = true
         Evaporation          = true
         RootWaterUptake      = true
			RootWaterUptakeComp  = true
			
		# SINK TERM 
         LookupTable_Lai           = true # <false> Lai=constant; <true> Lai varies per month
         LookUpTable_CropCoeficient = true # <false> CropCoeficient=constant; <true> CropCoeficient varies per month

		# HYDRAULIC MODEL 
			θΨKmodel = :Kosugi # <:vanGenuchten>; <:Kosugi>

		# RICHARDS EQUATION
			BottomBoundary = :Free # not working <:Free>; <:Pressure>
			∂R∂Ψ_Numerical = false # perform the derivatives numerically <true>; <false>

			# Adaptive time step
            # const Ψ_Constrain_K1     = false # <true>; <false>
				AdaptiveTimeStep   = :Δθ # <:ΔΨ>; <:Δθ>
		      NormMin            = :Norm		#<:Norm>; <:Min>
		      Flag_ReRun         = true # <true>; <false> Rerun after updating the ΔT
		      Qbottom_Correction = true # <true> correction for the mass balance of the last cell
		      # const NoConverge_Ψbest   = false # not working <true>; <false>* compute Q(Ψbest) when no convergence
		
		# RAINFALL INTERCEPTION MODEL
			Lai_2_SintMax = false # <true> derive Sint_Sat from LAI_2_SINTMAX; <false> derive from input file

		# STEP WISE OPTIMIZATION
			σ_2_Ψm = :No  # <:Constrained> Ψm physical feasible range is computed from σ <:UniqueRelationship> Ψm is computed from σ; <:No> optimisation of σ & Ψm with no constraints
			σ_2_θr = true # <true> derive θr from σ <false>
			θs_Opt = :No #  <:θs_Opt> θs is derived by multiplying a parameter to Max(θobs) for all profiles; <No>

		# CALIBRATION DATA AVAILABLE
         calibr  = true # <true>; <false>
			θobs_Hourly = true # θ data can be very large so we reduce the data to hourly
			Signature_Run = false

		# TABLE true
         Table = false 
          Table_Discretization  = true
          Table_Q               = true
          Table_RootWaterUptake = true
          Table_TimeSeries      = true
          Table_Ψ               = true
          Table_θ               = true
          Table_TimeSeriesDaily = true
          Tabule_θΨ             = true
          Table_Climate         = true
			
		# PLOT OUTPUTS
        Plot_Vegetation   = false
        Plot_θΨK          = false
        Plot_Interception = false
        Plot_Other        = true
        Plot_Sorptivity   = false
        Plot_Hypix        = true
          Plot_Climate      = true
          Plot_θ            = true
          Plot_Ψ            = true
          Plot_Flux         = true
          Plot_WaterBalance = true
          Plot_ΔT           = true

	 hypix = HYPIX(ClimateDataTimestep, RainfallInterception, Evaporation, RootWaterUptake, RootWaterUptakeComp, LookupTable_Lai, LookUpTable_CropCoeficient, θΨKmodel, BottomBoundary, ∂R∂Ψ_Numerical, AdaptiveTimeStep, NormMin, Flag_ReRun, Qbottom_Correction, Lai_2_SintMax, σ_2_Ψm, σ_2_θr, θs_Opt, calibr, θobs_Hourly, Signature_Run, Table, Table_Discretization, Table_Q, Table_RootWaterUptake, Table_TimeSeries, Table_Ψ, Table_θ, Table_TimeSeriesDaily, Tabule_θΨ, Table_Climate, Plot_Vegetation, Plot_θΨK, Plot_Interception, Plot_Other, Plot_Sorptivity, Plot_Hypix, Plot_Climate, Plot_θ, Plot_Ψ, Plot_Flux, Plot_WaterBalance, Plot_ΔT)


	# =============================================================
	#		global options
	# ===========================================================
	 HydroTranslateModel = false # <true>; <false>
    Hypix       = false # <true>; <false>
    Smap        = false # <true> ; <false>
	 AddPointKosugiBimodal = !(UsePointKosugiBimodal) # AddPointKosugiBimodal = true # <true> or <false>
	 BulkDensity = false # <true> <false>
    θΨ          = :No # <:Opt>* Optimize hydraulic parameters from θ(Ψ); <:File> from save file; <:No> not available
    Psd         = false	# <true> Derive θ(Ψ) AND/OR hydraulic parameters from Psd; <false>
    Infilt      = false # <true> Derive θ(Ψ) AND/OR hydraulic parameters from Infiltration data; <false>
    Temporary   = false # <true>; <false>
	 Jules = true # <true>; <false>
     	
	 # DOWNLAOD PACKAGES
    DownloadPackage = false # <true> For first time user download packages required to run program; <false>*

	 # PLOTTING
    Plot      = false # <true>* plot; <false> no plotting
    Plot_Show = false # <true>* plot shown in VScode; <false>
	
	 globalopt = GLOBALOPT(HydroTranslateModel, Hypix, Smap, AddPointKosugiBimodal, BulkDensity, θΨ, Psd, Infilt, Temporary, Jules, DownloadPackage, Plot, Plot_Show)

end # module option