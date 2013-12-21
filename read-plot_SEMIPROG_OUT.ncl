load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"
;************************************************************************
;procedure to automate plotting time series
undef("plot_tseries")
procedure plot_tseries(VarXY:numeric, VarXYName:string, \
                       XYLongName:string, XYUnits:string, \
                       XYTimeAxis:numeric, XYRes:logical)
local tswks, tsplot
begin
   VarXY!0 = "time"
   VarXY&time = XYTimeAxis
   VarXY@name = VarXYName
   VarXY@long_name = XYLongName
   VarXY@units = XYUnits
   XYRes@gsnLeftString = VarXY@long_name
   XYRes@gsnRightString = VarXY@units
   tswks = gsn_open_wks("epsi", "semiprog_"+VarXYName)
   tsplot = gsn_csm_xy(tswks, XYTimeAxis, VarXY, XYRes)
end
;************************************************************************
;procedure to automate the process of ploting profiles
undef("plot_profile")
procedure plot_profile(Var:numeric, \
                       VarName:string, \
                       LongName:string, \
                       Units:string, \
                       VertAxis:numeric, \
                       TimeAxis:numeric, \
		       Resource:logical)
local pwks, pplot
begin
   Var!0 = "plev"
   Var&plev = VertAxis ;pmid
   Var!1 = "time"
   Var&time = TimeAxis ;time
   Var@name = VarName
   Var@long_name = LongName
   Var@units = Units
   pwks = gsn_open_wks("epsi", "semiprog_"+VarName)
   pplot = gsn_csm_contour(pwks,Var,Resource)
end
;************************************************************************
begin
;  f = "/home/santiago/Modeling/SP-SAM/SEMIPROG_OUT"
   d = asciiread(f, -1, "string")
   dl = " "   ; field delimiter
   ncons = 3  ; number of constant fields, at the beginning of file 
   nvars = 38 ; number of time-var fields
   ; fields dimensions
   nx = stringtoint(str_get_field(d(0), 1, dl))
   ny = stringtoint(str_get_field(d(0), 2, dl))
   nz = stringtoint(str_get_field(d(0), 3, dl))
   nt = stringtoint(str_get_field(d(0), 4, dl))
   ; location characteristics
   tstep = stringtofloat(str_get_field(d(0), 5, dl))
   longi = stringtofloat(str_get_field(d(0), 6, dl))
   latit = stringtofloat(str_get_field(d(0), 7, dl))
   topog = stringtofloat(str_get_field(d(0), 8, dl))
   ocfrc = stringtofloat(str_get_field(d(0), 9, dl))
   ; pressure levels and layer pressure depth
   pmid = new((/nz/), float)
   pdel = new((/nz/), float)
   do k=0, nz-1
      pmid(k) = stringtofloat(str_get_field(d(1), k+1, dl))
      pdel(k) = stringtofloat(str_get_field(d(2), k+1, dl))
   end do
   ; variables to assign data in files
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
   ; time loop with nested vertical levels loop
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
   ;coordinates settings
   time = ispan(0,nt-1,1)
   timeUnits = "hours since 1997-06-18 00:00:00"
   time@units = timeUnits
   time@calendar = "gregorian"
   timeFormat = "%N/%D %H Z"
   restick = True
   restick@ttmFormat = timeFormat
   restick@ttmNumTicks = 6
   ;
   pmid@units = "hPa"
;  pmid@positive = "down"
   ;time series (xy-plot) resources
   resxy = True
   resxy@vpWidthF = 1.0
   resxy@vpHeightF = 0.2
   resxy@gsnMaximize = True
   resxy@gsnPaperOrientation = "portrait"
   resxy@tiYAxisString = ""
   time_axis_labels(time,resxy,restick)
   ;let's plot time series
   plot_tseries(precc*1000*3600,     "precc",     "Convective precipitation rate",                         "mm h-1",      time, resxy)
   plot_tseries(precl*1000*3600,     "precl",     "Stratiform precipitation rate",                         "mm h-1",      time, resxy)
   plot_tseries(precsc*1000*3600,    "precsc",    "Convective snow rate",                                  "mm h-1",      time, resxy)
   plot_tseries(precsl*1000*3600,    "precsl",    "Stratiform snow rate",                                  "mm h-1",      time, resxy)
   plot_tseries(cltot,     "cltot",     "Total cloud fraction",                                  "%",          time, resxy)
   plot_tseries(clhgh,     "clhgh",     "High cloud fraction",                                   "%",          time, resxy)
   plot_tseries(clmed,     "clmed",     "Middle cloud fraction",                                 "%",          time, resxy)
   plot_tseries(cllow,     "cllow",     "Low cloud fraction",                                    "%",          time, resxy)
   plot_tseries(taux_crm,  "taux_crm",  "Zonal CRM surface stress perturbation",                 "N m-2",      time, resxy)
   plot_tseries(tauy_crm,  "tauy_crm",  "Meridional CRM surface stress perturbation",            "N m-2",      time, resxy)
   plot_tseries(z0m,       "z0m",       "Surface stress",                                        "N m-2",      time, resxy)
   plot_tseries(prectend,  "prectend",  "Column integrated tendency in precipitating water+ice", "(kg/m2/s)",  time, resxy)
   plot_tseries(precstend, "precstend", "Column integrated tendency in precipitating ice",       "kg m-2 s-1", time, resxy)
   ;resources for time varying profiles
   res = True
   res@cnFillOn = True
   res@cnLinesOn = False
   res@lbOrientation = "Vertical"
   res@vpWidthF = 1.0
   res@vpHeightF = 0.2
   res@gsnMaximize = True
   res@gsnPaperOrientation = "portrait"
   res@trYReverse = True
   time_axis_labels(time,res,restick)
   ;let's plot profiles
   plot_profile (zmid,       "zmid",       "Metric height",                                  "m",           pmid, time, res)
   plot_profile (ultend,     "ultend",     "Tendency of zonal wind",                         "m s-2",       pmid, time, res)
   plot_profile (vltend,     "vltend",     "Tendency of merid wind",                         "m s-2",       pmid, time, res)   
   plot_profile (qltend,     "qltend",     "Tendency of water vapor",                        "kg kg-1 s-1", pmid, time, res)
   plot_profile (qcltend,    "qcltend",    "Tendency of cloud liquid water",                 "?",           pmid, time, res)
   plot_profile (qcitend,    "qcitend",    "Tendency of cloud ice",                          "?",           pmid, time, res)
   plot_profile (sltend,     "sltend",     "Tendency of static energy",                      "?",           pmid, time, res)
   plot_profile (cld,        "cld",        "Cloud fraction",                                 "%",           pmid, time, res)
   plot_profile (cldr,       "cldr",       "Cloud frac. based on -30dBZ radar reflectivity", "?",           pmid, time, res)
   plot_profile (cldtop,     "cldtop",     "Cloud top PDF",                                  "?",           pmid, time, res)
   plot_profile (gicewp,     "gicewp",     "Ice water path",                                 "?",           pmid, time, res)
   plot_profile (gliqwp,     "gliqwp",     "Liquid water path",                              "?",           pmid, time, res)
   plot_profile (mc,         "mc",         "Cloud mass flux",                                "s-1",         pmid, time, res)
   plot_profile (mcup,       "mcup",       "Updraft cloud mass flux",                        "s-1",         pmid, time, res)
   plot_profile (mcdn,       "mcdn",       "Downdraft cloud mass flux",                      "s-1",         pmid, time, res)
   plot_profile (mcuup,      "mcuup",      "Unsat. updraft cloud mass flux",                 "s-1",         pmid, time, res)
   plot_profile (mcudn,      "mcudn",      "Unsat. downdraft cloud mass flux",               "s-1",         pmid, time, res)
   plot_profile (crm_qc,     "crm_qc",     "CRM mean cloud water",                           "kg kg-1",     pmid, time, res)
   plot_profile (crm_qi,     "crm_qi",     "Mean cloud ice",                                 "?",           pmid, time, res)
   plot_profile (crm_qs,     "crm_qs",     "Mean snow",                                      "?",           pmid, time, res)
   plot_profile (crm_qg,     "crm_qg",     "Mean graupel",                                   "?",           pmid, time, res)
   plot_profile (crm_qr,     "crm_qr",     "Mean rain",                                      "?",           pmid, time, res)
   plot_profile (tkez,       "tkez",       "TKE profile",                                    "J kg-1",      pmid, time, res)
   plot_profile (tkesgsz,    "tkesgsz",    "SGS TKE profile",                                "J kg-1",      pmid, time, res)
   plot_profile (flux_u,     "flux_u",     "Zonal wind flux",                                "?",           pmid, time, res)
   plot_profile (flux_v,     "flux_v",     "Meridional wind flux",                           "?",           pmid, time, res)
   plot_profile (flux_qt,    "flux_qt",    "Non-precipitating water flux",                   "?",           pmid, time, res)
   plot_profile (fluxsgs_qt, "fluxsgs_qt", "SGS non-precipitating water flux",               "?",           pmid, time, res)
   plot_profile (flux_qp,    "flux_qp",    "Precipitating water flux",                       "?",           pmid, time, res)
   plot_profile (pflx,       "pflx",       "Precipitation flux",                             "?",           pmid, time, res)
   plot_profile (qt_ls,      "qt_ls",      "Tendency of non-prec. water due to large-scale", "?",           pmid, time, res)
   plot_profile (qt_trans,   "qt_trans",   "Tendency of non-prec. water due to transport",   "?",           pmid, time, res)
   plot_profile (qp_trans,   "qp_trans",   "Tendency of prec. water due to transport",       "?",           pmid, time, res)
   plot_profile (qp_fall,    "qp_fall",    "Tendency of prec. water due to fall out",        "?",           pmid, time, res)
   plot_profile (qp_evp,     "qp_evp",     "Tendency of prec. water due to evaporation",     "?",           pmid, time, res)
   plot_profile (qp_src,     "qp_src",     "Tendency of prec. water due to conversion",      "?",           pmid, time, res)
   plot_profile (t_ls,       "t_ls",       "Tendency of lwse due to large-scale",            "?",           pmid, time, res)
end
