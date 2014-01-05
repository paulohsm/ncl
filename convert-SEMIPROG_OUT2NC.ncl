;  This scripts aims to read the SP-SAM semoprognostic test output SEMIPRO_OUT
;+ file, assign variable attributes and write a netCDF output.
;
;  SEMIPROG_OUT is an ASCII file where the first line provides infor-
;+ mation about the model, such as number of grid points and grid 
;+ spacing. The number of time records is calculated regarding the
;+ number of lines inf file and the number of variables stored - that
;+ is why you must provide the number of variables.
;==how about write this number in SEMIPROG_OUT???=================
;
;  Usage:
;  ncl convert-SEMIPROG_OUT2NC.ncl 'f="/path/to/SEMIPROG_OUT"'
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;
procedure nc_tseries(ncFileName:file, Var:numeric, VarName:string, \
	VarLongName:string, VarUnits:string, TimeCoord:numeric)
begin
   Var!0 = "time"
   Var&time = TimeCoord
   Var@name = VarName
   Var@long_name = VarLongName
   Var@units = VarUnits
   ncFileName->$VarName$ = Var
end
	
procedure nc_profile(ncFileName:file, Var:numeric, VarName:string, \
	VarLongName:string, VarUnits:string, PresCoord:numeric, TimeCoord:numeric)
begin
   Var!0 = "plev"
   Var&plev = PresCoord
   Var!1 = "time"
   Var&time = TimeCoord
   Var@name = VarName
   Var@long_name = VarLongName
   Var@units = VarUnits
   ncFileName->$VarName$ = Var
end

begin
   f = "SEMIPROG_OUT"
;  SEMIPROG_OUT file path is passed as argument. However, you can 
;+ uncomment the line above and provide your own file path if you 
;+ prefer.
;
   d = asciiread(f, -1, "string")
   dl = " "   ; field delimiter
   ncons = 3  ; number of constant fields, at the beginning of file 
   nvars = 38 ; number of time-var fields
;  Variables are read as string (every line is a string) and then 
;+ decomposed as numeric variables.
;  Fields dimensions:
   nx = stringtoint(str_get_field(d(0), 1, dl))
   ny = stringtoint(str_get_field(d(0), 2, dl))
   nz = stringtoint(str_get_field(d(0), 3, dl))
   nt = stringtoint(str_get_field(d(0), 4, dl))
;  Location characteristics:
   tstep = stringtofloat(str_get_field(d(0), 5, dl))
   longi = stringtofloat(str_get_field(d(0), 6, dl))
   latit = stringtofloat(str_get_field(d(0), 7, dl))
   topog = stringtofloat(str_get_field(d(0), 8, dl))
   ocfrc = stringtofloat(str_get_field(d(0), 9, dl))
;  Pressure levels and layer pressure depth:
   pmid = new((/nz/), float)
   pdel = new((/nz/), float)
   do k=0, nz-1
      pmid(k) = stringtofloat(str_get_field(d(1), k+1, dl))
      pdel(k) = stringtofloat(str_get_field(d(2), k+1, dl))
   end do
;  Empty variables to assign data in files:
   precc     = new((/nt/), float) ; Convective precip rate (m/s)
   precl     = new((/nt/), float) ; Stratiform precip rate (m/s)
   precsc    = new((/nt/), float) ; Convective snow rate (m/s)
   precsl    = new((/nt/), float) ; Stratiform snow rate (m/s)
   cltot     = new((/nt/), float) ; Shaded cloud fraction (%)
   clhgh     = new((/nt/), float) ; Shaded cloud fraction (%)
   clmed     = new((/nt/), float) ; Shaded cloud fraction (%)
   cllow     = new((/nt/), float) ; Shaded cloud fraction (%)
   taux_crm  = new((/nt/), float) ; Zon. CRM sfc. stress pert. (N/m2)
   tauy_crm  = new((/nt/), float) ; Mer. CRM sfc. stress pert. (N/m2)
   z0m       = new((/nt/), float) ; Surface stress (N/m2)
   prectend  = new((/nt/), float) ; Col. int. tend. in prec. water+ice (kg/m2/s)
   precstend = new((/nt/), float) ; Col. int. tend. in prec. ice (kg/m2/s)
   zmid       = new((/nz,nt/), float)
   ultend     = new((/nz,nt/), float)
   vltend     = new((/nz,nt/), float)
   qltend     = new((/nz,nt/), float)
   qcltend    = new((/nz,nt/), float)
   qcitend    = new((/nz,nt/), float)
   sltend     = new((/nz,nt/), float)
   cld        = new((/nz,nt/), float)
   cldr       = new((/nz,nt/), float)
   cldtop     = new((/nz,nt/), float)
   gicewp     = new((/nz,nt/), float)
   gliqwp     = new((/nz,nt/), float)
   mc         = new((/nz,nt/), float)
   mcup       = new((/nz,nt/), float)
   mcdn       = new((/nz,nt/), float) 
   mcuup      = new((/nz,nt/), float)
   mcudn      = new((/nz,nt/), float)
   crm_qc     = new((/nz,nt/), float)
   crm_qi     = new((/nz,nt/), float)
   crm_qs     = new((/nz,nt/), float)
   crm_qg     = new((/nz,nt/), float)
   crm_qr     = new((/nz,nt/), float)
   tkez       = new((/nz,nt/), float)
   tkesgsz    = new((/nz,nt/), float)
   flux_u     = new((/nz,nt/), float)
   flux_v     = new((/nz,nt/), float)
   flux_qt    = new((/nz,nt/), float)
   fluxsgs_qt = new((/nz,nt/), float)
   flux_qp    = new((/nz,nt/), float)
   pflx       = new((/nz,nt/), float)
   qt_ls      = new((/nz,nt/), float)
   qt_trans   = new((/nz,nt/), float)
   qp_trans   = new((/nz,nt/), float)
   qp_fall    = new((/nz,nt/), float)
   qp_evp     = new((/nz,nt/), float)
   qp_src     = new((/nz,nt/), float)
   t_ls       = new((/nz,nt/), float)
;  Time loop with nested vertical levels loop:
   do l=0,nt-1
      nl = ncons + nvars * l ; nl = line number in file, first = 0
      precc(l)     = stringtofloat(str_get_field(d(nl),  1, dl))
      precl(l)     = stringtofloat(str_get_field(d(nl),  2, dl))
      precsc(l)    = stringtofloat(str_get_field(d(nl),  3, dl))
      precsl(l)    = stringtofloat(str_get_field(d(nl),  4, dl))
      cltot(l)     = stringtofloat(str_get_field(d(nl),  5, dl))
      clhgh(l)     = stringtofloat(str_get_field(d(nl),  6, dl))
      clmed(l)     = stringtofloat(str_get_field(d(nl),  7, dl))
      cllow(l)     = stringtofloat(str_get_field(d(nl),  8, dl))
      taux_crm(l)  = stringtofloat(str_get_field(d(nl),  9, dl))
      tauy_crm(l)  = stringtofloat(str_get_field(d(nl), 10, dl))
      z0m(l)       = stringtofloat(str_get_field(d(nl), 11, dl))
      prectend(l)  = stringtofloat(str_get_field(d(nl), 12, dl))
      precstend(l) = stringtofloat(str_get_field(d(nl), 13, dl))
      do k=0,nz-1
         zmid(k,l)       = stringtofloat(str_get_field(d(nl +1), k+1, dl))
         ultend(k,l)     = stringtofloat(str_get_field(d(nl +2), k+1, dl))
         vltend(k,l)     = stringtofloat(str_get_field(d(nl +3), k+1, dl))
         qltend(k,l)     = stringtofloat(str_get_field(d(nl +4), k+1, dl))
         qcltend(k,l)    = stringtofloat(str_get_field(d(nl +5), k+1, dl))
         qcitend(k,l)    = stringtofloat(str_get_field(d(nl +6), k+1, dl))
         sltend(k,l)     = stringtofloat(str_get_field(d(nl +7), k+1, dl))
         cld(k,l)        = stringtofloat(str_get_field(d(nl +8), k+1, dl))
         cldr(k,l)       = stringtofloat(str_get_field(d(nl +9), k+1, dl))
         cldtop(k,l)     = stringtofloat(str_get_field(d(nl+10), k+1, dl))
         gicewp(k,l)     = stringtofloat(str_get_field(d(nl+11), k+1, dl))
         gliqwp(k,l)     = stringtofloat(str_get_field(d(nl+12), k+1, dl))
         mc(k,l)         = stringtofloat(str_get_field(d(nl+13), k+1, dl))
         mcup(k,l)       = stringtofloat(str_get_field(d(nl+14), k+1, dl))
         mcdn(k,l)       = stringtofloat(str_get_field(d(nl+15), k+1, dl))
         mcuup(k,l)      = stringtofloat(str_get_field(d(nl+16), k+1, dl))
         mcudn(k,l)      = stringtofloat(str_get_field(d(nl+17), k+1, dl))
         crm_qc(k,l)     = stringtofloat(str_get_field(d(nl+18), k+1, dl))
         crm_qi(k,l)     = stringtofloat(str_get_field(d(nl+19), k+1, dl))
         crm_qs(k,l)     = stringtofloat(str_get_field(d(nl+20), k+1, dl))
         crm_qg(k,l)     = stringtofloat(str_get_field(d(nl+21), k+1, dl))
         crm_qr(k,l)     = stringtofloat(str_get_field(d(nl+22), k+1, dl))
         tkez(k,l)       = stringtofloat(str_get_field(d(nl+23), k+1, dl))
         tkesgsz(k,l)    = stringtofloat(str_get_field(d(nl+24), k+1, dl))
         flux_u(k,l)     = stringtofloat(str_get_field(d(nl+25), k+1, dl))
         flux_v(k,l)     = stringtofloat(str_get_field(d(nl+26), k+1, dl))
         flux_qt(k,l)    = stringtofloat(str_get_field(d(nl+27), k+1, dl))
         fluxsgs_qt(k,l) = stringtofloat(str_get_field(d(nl+28), k+1, dl))
         flux_qp(k,l)    = stringtofloat(str_get_field(d(nl+29), k+1, dl))
         pflx(k,l)       = stringtofloat(str_get_field(d(nl+30), k+1, dl))
         qt_ls(k,l)      = stringtofloat(str_get_field(d(nl+31), k+1, dl))
         qt_trans(k,l)   = stringtofloat(str_get_field(d(nl+32), k+1, dl))
         qp_trans(k,l)   = stringtofloat(str_get_field(d(nl+33), k+1, dl))
         qp_fall(k,l)    = stringtofloat(str_get_field(d(nl+34), k+1, dl))
         qp_evp(k,l)     = stringtofloat(str_get_field(d(nl+35), k+1, dl))
         qp_src(k,l)     = stringtofloat(str_get_field(d(nl+36), k+1, dl))
         t_ls(k,l)       = stringtofloat(str_get_field(d(nl+37), k+1, dl))
      end do
   end do
;  Creating coordinate dimensions
   pmid@units = "hPa"
   pmid@positive = "down"
   time = ispan(0,nt-1,1)
   timeUnits = "hours since 1997-06-18 00:00:00"
   time@units = timeUnits
   time@calendar = "gregorian"
;  Once all variables are read we start the netcdf operations
   ncfileout = "SEMIPROG_OUT.nc"
;  setfileoption("nc","format","netcdf4")
;  setfileoption("nc","headerReverseSpace",64000)
;  setfileoption("nc","preFill",False)
   if (isfilepresent(ncfileout)) then
      system("rm "+ncfileout)
   end if
   ncfile = addfile(ncfileout,"c")
;  Setting file dimensions
   dim_names = (/"plev","time"/)
   dim_sizes = (/nz,nt/)
   dim_unlim = (/False,False/)
   filedimdef(ncfile, dim_names, dim_sizes, dim_unlim)
;  Writing time series
   nc_tseries (ncfile, precc,     "precc",     "Convective precip rate",                                "mm h-1",     time)
   nc_tseries (ncfile, precl,     "precl",     "Stratiform precipitation rate",                         "mm h-1",     time)
   nc_tseries (ncfile, precsc,    "precsc",    "Convective snow rate",                                  "mm h-1",     time)
   nc_tseries (ncfile, precsl,    "precsl",    "Stratiform snow rate",                                  "mm h-1",     time)
   nc_tseries (ncfile, cltot,     "cltot",     "Total cloud fraction",                                  "%",          time)
   nc_tseries (ncfile, clhgh,     "clhgh",     "High cloud fraction",                                   "%",          time)
   nc_tseries (ncfile, clmed,     "clmed",     "Middle cloud fraction",                                 "%",          time)
   nc_tseries (ncfile, cllow,     "cllow",     "Low cloud fraction",                                    "%",          time)
   nc_tseries (ncfile, taux_crm,  "taux_crm",  "Zonal CRM surface stress perturbation",                 "N m-2",      time)
   nc_tseries (ncfile, tauy_crm,  "tauy_crm",  "Meridional CRM surface stress perturbation",            "N m-2",      time)
   nc_tseries (ncfile, z0m,       "z0m",       "Surface stress",                                        "N m-2",      time)
   nc_tseries (ncfile, prectend,  "prectend",  "Column integrated tendency in precipitating water+ice", "kg m-2 s-1", time)
   nc_tseries (ncfile, precstend, "precstend", "Column integrated tendency in precipitating ice",       "kg m-2 s-1", time)
;  Writing profiles
   nc_profile (ncfile, zmid,       "zmid",       "Metric height",                                  "m",           pmid, time)
   nc_profile (ncfile, ultend,     "ultend",     "Tendency of zonal wind",                         "m s-2",       pmid, time)
   nc_profile (ncfile, vltend,     "vltend",     "Tendency of merid wind",                         "m s-2",       pmid, time)   
   nc_profile (ncfile, qltend,     "qltend",     "Tendency of water vapor",                        "kg kg-1 s-1", pmid, time)
   nc_profile (ncfile, qcltend,    "qcltend",    "Tendency of cloud liquid water",                 "?",           pmid, time)
   nc_profile (ncfile, qcitend,    "qcitend",    "Tendency of cloud ice",                          "?",           pmid, time)
   nc_profile (ncfile, sltend,     "sltend",     "Tendency of static energy",                      "?",           pmid, time)
   nc_profile (ncfile, cld,        "cld",        "Cloud fraction",                                 "%",           pmid, time)
   nc_profile (ncfile, cldr,       "cldr",       "Cloud frac. based on -30dBZ radar reflectivity", "?",           pmid, time)
   nc_profile (ncfile, cldtop,     "cldtop",     "Cloud top PDF",                                  "?",           pmid, time)
   nc_profile (ncfile, gicewp,     "gicewp",     "Ice water path",                                 "?",           pmid, time)
   nc_profile (ncfile, gliqwp,     "gliqwp",     "Liquid water path",                              "?",           pmid, time)
   nc_profile (ncfile, mc,         "mc",         "Cloud mass flux",                                "s-1",         pmid, time)
   nc_profile (ncfile, mcup,       "mcup",       "Updraft cloud mass flux",                        "s-1",         pmid, time)
   nc_profile (ncfile, mcdn,       "mcdn",       "Downdraft cloud mass flux",                      "s-1",         pmid, time)
   nc_profile (ncfile, mcuup,      "mcuup",      "Unsat. updraft cloud mass flux",                 "s-1",         pmid, time)
   nc_profile (ncfile, mcudn,      "mcudn",      "Unsat. downdraft cloud mass flux",               "s-1",         pmid, time)
   nc_profile (ncfile, crm_qc,     "crm_qc",     "CRM mean cloud water",                           "kg kg-1",     pmid, time)
   nc_profile (ncfile, crm_qi,     "crm_qi",     "Mean cloud ice",                                 "?",           pmid, time)
   nc_profile (ncfile, crm_qs,     "crm_qs",     "Mean snow",                                      "?",           pmid, time)
   nc_profile (ncfile, crm_qg,     "crm_qg",     "Mean graupel",                                   "?",           pmid, time)
   nc_profile (ncfile, crm_qr,     "crm_qr",     "Mean rain",                                      "?",           pmid, time)
   nc_profile (ncfile, tkez,       "tkez",       "TKE profile",                                    "J kg-1",      pmid, time)
   nc_profile (ncfile, tkesgsz,    "tkesgsz",    "SGS TKE profile",                                "J kg-1",      pmid, time)
   nc_profile (ncfile, flux_u,     "flux_u",     "Zonal wind flux",                                "?",           pmid, time)
   nc_profile (ncfile, flux_v,     "flux_v",     "Meridional wind flux",                           "?",           pmid, time)
   nc_profile (ncfile, flux_qt,    "flux_qt",    "Non-precipitating water flux",                   "?",           pmid, time)
   nc_profile (ncfile, fluxsgs_qt, "fluxsgs_qt", "SGS non-precipitating water flux",               "?",           pmid, time)
   nc_profile (ncfile, flux_qp,    "flux_qp",    "Precipitating water flux",                       "?",           pmid, time)
   nc_profile (ncfile, pflx,       "pflx",       "Precipitation flux",                             "?",           pmid, time)
   nc_profile (ncfile, qt_ls,      "qt_ls",      "Tendency of non-prec. water due to large-scale", "?",           pmid, time)
   nc_profile (ncfile, qt_trans,   "qt_trans",   "Tendency of non-prec. water due to transport",   "?",           pmid, time)
   nc_profile (ncfile, qp_trans,   "qp_trans",   "Tendency of prec. water due to transport",       "?",           pmid, time)
   nc_profile (ncfile, qp_fall,    "qp_fall",    "Tendency of prec. water due to fall out",        "?",           pmid, time)
   nc_profile (ncfile, qp_evp,     "qp_evp",     "Tendency of prec. water due to evaporation",     "?",           pmid, time)
   nc_profile (ncfile, qp_src,     "qp_src",     "Tendency of prec. water due to conversion",      "?",           pmid, time)
   nc_profile (ncfile, t_ls,       "t_ls",       "Tendency of lwse due to large-scale",            "?",           pmid, time)
end


