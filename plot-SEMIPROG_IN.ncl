load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/calendar_decode2.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

;  f = "/Users/santiago/Modeling/SP-SAM/get_SP-SAM_input/SEMIPROG_IN"
   f = "/home/santiago/Modeling/SP-SAM/SEMIPROG_IN"
   d = asciiread(f, -1, "string")
   tabkey = "	"
;decompose first string/line in file into its respectives variables
   nz    = stringtoint(str_get_field(d(0), 1, tabkey))
   tstep = stringtofloat(str_get_field(d(0), 2, tabkey))
   lon   = stringtofloat(str_get_field(d(0), 3, tabkey))
   lat   = stringtofloat(str_get_field(d(0), 4, tabkey))
   topo  = stringtofloat(str_get_field(d(0), 5, tabkey))
   lsmk  = stringtoint(str_get_field(d(0), 6, tabkey))
;before start the loop over time and vertical, we have to set up the variables
   nrec = (dimsizes(d) - 1) / (nz + 2) ; explanation:
   ; divide the number of lines in file subtratced the first line by the number
   ; of lines in each time record, which is the number of vertical levels added
   ; two lines for time varying surface variables
   pres = new((/nz/), float)
   tlev = new((/nrec/), string)
   pslc = new((/nrec/), float)
   usst = new((/nrec/), float)
   vsst = new((/nrec/), float)
   cssf = new((/nrec/), float)
   clsf = new((/nrec/), float)
   ocis = new((/nrec/), float)
   oces = new((/nrec/), float)
   iswf = new((/nrec/), float)
   roce = new((/nrec/), float) ; those are the 2nd line of time variables
   olis = new((/nrec/), float)
   oles = new((/nrec/), float)
   role = new((/nrec/), float)
   swtc = new((/nrec/), float)
   ocic = new((/nrec/), float)
   lwtc = new((/nrec/), float)
   lwbc = new((/nrec/), float)
   temp = new((/nz,nrec/), float) ; time varying vertical profiles
   umes = new((/nz,nrec/), float)
   liqm = new((/nz,nrec/), float)
   icem = new((/nz,nrec/), float)
   uvel = new((/nz,nrec/), float)
   vvel = new((/nz,nrec/), float)
   swrh = new((/nz,nrec/), float)
   lwrh = new((/nz,nrec/), float)
;now we start a loop over time
   do l=0,nrec-1 ; l is the time record counter
      n = l * (nz+2) + 1; n is the line number starting at 0
      tlev(l) = str_get_field(d(n), 1, tabkey)
      pslc(l) = stringtofloat(str_get_field(d(n), 2, tabkey))
      usst(l) = stringtofloat(str_get_field(d(n), 3, tabkey))
      vsst(l) = stringtofloat(str_get_field(d(n), 4, tabkey))
      cssf(l) = stringtofloat(str_get_field(d(n), 5, tabkey))
      clsf(l) = stringtofloat(str_get_field(d(n), 6, tabkey))
      ocis(l) = stringtofloat(str_get_field(d(n), 7, tabkey))
      oces(l) = stringtofloat(str_get_field(d(n), 8, tabkey))
      iswf(l) = stringtofloat(str_get_field(d(n), 9, tabkey))
      roce(l) = stringtofloat(str_get_field(d(n+1), 1, tabkey))
      olis(l) = stringtofloat(str_get_field(d(n+1), 2, tabkey))
      oles(l) = stringtofloat(str_get_field(d(n+1), 3, tabkey))
      role(l) = stringtofloat(str_get_field(d(n+1), 4, tabkey))
      swtc(l) = stringtofloat(str_get_field(d(n+1), 5, tabkey))
      ocic(l) = stringtofloat(str_get_field(d(n+1), 6, tabkey))
      lwtc(l) = stringtofloat(str_get_field(d(n+1), 7, tabkey))
      lwbc(l) = stringtofloat(str_get_field(d(n+1), 8, tabkey))
;nested to time loop we run a loop over vertical coordinates
      do k=0,nz-1 ; loop over k, the vertical level counter
	 nk = n + 2 + k ; mapping the line number in file regarding the vertical level counting
	 pres(k) = stringtofloat(str_get_field(d(nk), 1, tabkey))
	 temp(k,l) = stringtofloat(str_get_field(d(nk), 2, tabkey))
	 umes(k,l) = stringtofloat(str_get_field(d(nk), 3, tabkey))
	 liqm(k,l) = stringtofloat(str_get_field(d(nk), 4, tabkey))
	 icem(k,l) = stringtofloat(str_get_field(d(nk), 5, tabkey))
	 uvel(k,l) = stringtofloat(str_get_field(d(nk), 6, tabkey))
	 vvel(k,l) = stringtofloat(str_get_field(d(nk), 7, tabkey))
         swrh(k,l) = stringtofloat(str_get_field(d(nk), 8, tabkey))
         lwrh(k,l) = stringtofloat(str_get_field(d(nk), 9, tabkey))
      end do
   end do
;set up a time coordinate -- how?
; 1. create an array for time values
; 2. give it proper time units and calendar
; 3. use time_axis_labels to assign a format
; http://www.ncl.ucar.edu/Document/Functions/User_contributed/time_axis_labels.shtml
   time       = ispan(0,nrec-1,1)
   timeUnits  = "hours since 1997-06-18 00:00:00"
   time@units = timeUnits
   time@calendar = "gregorian"
   timeFormat = "%N/%D %H Z"
   restick = True ; resource used to assign nice time labels
   restick@ttmFormat = timeFormat
;in order to get the plots, let's set some attributes to the variables
   pres@units = "millibar" ;"hpa" ;"hPa"
   pres@positive = "down"
   ; -- temperatura
   temp!0 = "lev"
   temp!1 = "time"
   temp&lev  = pres
   temp&time = time
   temp@long_name = "Temperatura"
   temp@units = "K"
   ; -- umidade especifica
   umes!0 = "lev"
   umes&lev = pres
   umes!1 = "time"
   umes&time = time
   umes@long_name = "Umidade Especifica"
   umes@units = "kg/kg"
   ; -- vento zonal
   uvel!0 = "lev"
   uvel&lev = pres
   uvel!1 = "time"
   uvel&time = time
   uvel@long_name = "Vento Zonal"
   uvel@units = "m/s"
   ; -- vento meridional
   vvel!0 = "lev"
   vvel&lev = pres
   vvel!1 = "time"
   vvel&time = time
   vvel@long_name = "Vento Meridional"
   vvel@units = "m/s"
   ; -- aquecimento radiativo oc
   swrh!0 = "lev"
   swrh&lev = pres
   swrh!1 = "time"
   swrh&time = time
   swrh@long_name = "Aquecimento Radiativo por OC"
   swrh@units = "K/s"
   ; -- aquecimento radiativo ol
   lwrh!0 = "lev"
   lwrh&lev = pres
   lwrh!1 = "time"
   lwrh&time = time
   lwrh@long_name = "Aquecimento Radiativo por OL"
   lwrh@units = "K/s"
   ; -- pressao na superficie
   pslc!0 = "time"
   pslc&time = time
   pslc@long_name = "Pressao na Superficie"
   pslc@units = "hPa"
   ; -- tensao superficial zonal
   usst!0 = "time"
   usst&time = time
   usst@long_name = "Tensao Superficial do Vento Zonal"
   usst@units = "Pa"
   ; -- tensao superficial vento meridional
   vsst!0 = "time"
   vsst&time = time
   vsst@long_name = "Tensao Superficial do Vento Meridional"
   vsst@units = "Pa"
   ; -- fluxo de calor sensivel
   cssf!0 = "time"
   cssf&time = time
   cssf@long_name = "Fluxo de Calor Sensivel"
   cssf@units = "W/m2"
   ; -- fluxo de calor latente
   clsf!0 = "time"
   clsf&time = time
   clsf@long_name = "Fluxo de Calor Latente"
   clsf@units = "W/m2"
   ; -- DOWNWARD SHORT WAVE AT GROUND
   ocis!0 = "time"
   ocis&time = time
   ocis@long_name = "DOWNWARD SHORT WAVE AT GROUND"
   ocis@units = "W/m2"
   ; -- UPWARD SHORT WAVE AT GROUND
   oces!0 = "time"
   oces&time = time
   oces@long_name = "UPWARD SHORT WAVE AT GROUND"
   oces@units = "W/m2"
   ; -- INCIDENT SHORT WAVE FLUX
   iswf!0 = "time"
   iswf&time = time
   iswf@long_name = "INCIDENT SHORT WAVE FLUX"
   iswf@units = "W/m2" 
   ; -- UPWARD SHORT WAVE AT TOP
   roce!0 = "time"
   roce&time = time
   roce@long_name = "UPWARD SHORT WAVE AT TOP"
   roce@units = "W/m2"
   ; -- DOWNWARD LONG WAVE AT BOTTOM
   olis!0 = "time"
   olis&time = time
   olis@long_name = "DOWNWARD LONG WAVE AT BOTTOM"
   olis@units = "W/m2"
   ; -- UPWARD LONG WAVE AT BOTTOM
   oles!0 = "time"
   oles&time = time
   oles@long_name = "UPWARD LONG WAVE AT BOTTOM"
   oles@units = "W/m2"
   ; -- OUTGOING LONG WAVE AT TOP
   role!0 = "time"
   role&time = time
   role@long_name = "OUTGOING LONG WAVE AT TOP"
   role@units = "W/m2"
   ; -- UPWARD SHORT WAVE AT TOP (CLEAR)
   swtc!0 = "time"
   swtc&time = time
   swtc@long_name = "UPWARD SHORT WAVE AT TOP (CLEAR)"
   swtc@units = "W/m2"
   ; -- DOWNWARD SHORT WAVE AT GROUND (CLEAR)
   ocic!0 = "time"
   ocic&time = time
   ocic@long_name = "DOWNWARD SHORT WAVE AT GROUND (CLEAR)"
   ocic@units = "W/m2"
   ; -- OUTGOING LONG WAVE AT TOP (CLEAR)
   lwtc!0 = "time"
   lwtc&time = time
   lwtc@long_name = "OUTGOING LONG WAVE AT TOP (CLEAR)"
   lwtc@units = "W/m2"
   ; -- NET LONG WAVE AT BOTTOM (CLEAR)
   lwbc!0 = "time"
   lwbc&time = time
   lwbc@long_name = "NET LONG WAVE AT BOTTOM (CLEAR)"
   lwbc@units = "W/m2"
;resources for xy plots
   resxy = True
   resxy@vpWidthF = 1.0
   resxy@vpHeightF = 0.2
   resxy@gsnMaximize = True
   resxy@gsnPaperOrientation = "portrait"
   time_axis_labels(time,resxy,restick)
   resxy@tiYAxisString = ""
;xy-plots
   wks_xy = gsn_open_wks("epsi","agcm_pslc")
   resxy@gsnLeftString = pslc@long_name
   resxy@gsnRightString = pslc@units
   plot = gsn_csm_xy(wks_xy,time,pslc,resxy)

   wks_xy = gsn_open_wks("epsi","agcm_usst")
   resxy@gsnLeftString = usst@long_name
   resxy@gsnRightString = usst@units
   plot = gsn_csm_xy(wks_xy,time,usst,resxy)

   wks_xy = gsn_open_wks("epsi","agcm_vsst")
   resxy@gsnLeftString = vsst@long_name
   resxy@gsnRightString = vsst@units   
   plot = gsn_csm_xy(wks_xy,time,vsst,resxy)

   wks_xy = gsn_open_wks("epsi","agcm_cssf")
   resxy@gsnLeftString = cssf@long_name
   resxy@gsnRightString = cssf@units
   plot = gsn_csm_xy(wks_xy,time,cssf,resxy)   

   wks_xy = gsn_open_wks("epsi","agcm_clsf")
   resxy@gsnLeftString = clsf@long_name
   resxy@gsnRightString = clsf@units
   plot = gsn_csm_xy(wks_xy,time,clsf,resxy)   

   wks_xy = gsn_open_wks("epsi","agcm_ocis")
   resxy@gsnLeftString = ocis@long_name
   resxy@gsnRightString = ocis@units
   plot = gsn_csm_xy(wks_xy,time,ocis,resxy)   

   wks_xy = gsn_open_wks("epsi","agcm_oces")
   resxy@gsnLeftString = oces@long_name
   resxy@gsnRightString = oces@units
   plot = gsn_csm_xy(wks_xy,time,oces,resxy)   

   wks_xy = gsn_open_wks("epsi","agcm_iswf")
   resxy@gsnLeftString = iswf@long_name
   resxy@gsnRightString = iswf@units
   plot = gsn_csm_xy(wks_xy,time,iswf,resxy)   

   wks_xy = gsn_open_wks("epsi","agcm_roce")
   resxy@gsnLeftString = roce@long_name
   resxy@gsnRightString = roce@units
   plot = gsn_csm_xy(wks_xy,time,roce,resxy)   

   wks_xy = gsn_open_wks("epsi","agcm_olis")
   resxy@gsnLeftString = olis@long_name
   resxy@gsnRightString = olis@units
   plot = gsn_csm_xy(wks_xy,time,olis,resxy)   

   wks_xy = gsn_open_wks("epsi","agcm_oles")
   resxy@gsnLeftString = oles@long_name
   resxy@gsnRightString = oles@units
   plot = gsn_csm_xy(wks_xy,time,oles,resxy)   

   wks_xy = gsn_open_wks("epsi","agcm_role")
   resxy@gsnLeftString = role@long_name
   resxy@gsnRightString = role@units
   plot = gsn_csm_xy(wks_xy,time,role,resxy)   

   wks_xy = gsn_open_wks("epsi","agcm_swtc")
   resxy@gsnLeftString = swtc@long_name
   resxy@gsnRightString = swtc@units
   plot = gsn_csm_xy(wks_xy,time,swtc,resxy)   

   wks_xy = gsn_open_wks("epsi","agcm_ocic")
   resxy@gsnLeftString = ocic@long_name
   resxy@gsnRightString = ocic@units
   plot = gsn_csm_xy(wks_xy,time,ocic,resxy)   

   wks_xy = gsn_open_wks("epsi","agcm_lwtc")
   resxy@gsnLeftString = lwtc@long_name
   resxy@gsnRightString = lwtc@units
   plot = gsn_csm_xy(wks_xy,time,lwtc,resxy)   

   wks_xy = gsn_open_wks("epsi","agcm_lwbc")
   resxy@gsnLeftString = lwbc@long_name
   resxy@gsnRightString = lwbc@units
   plot = gsn_csm_xy(wks_xy,time,lwbc,resxy)   
;   
;resources for vertical profiles plots
   res = True
   res@cnFillOn = True
   res@cnLinesOn = False
   res@lbOrientation = "Vertical"
   res@vpHeightF = 0.2 ;0.3
   res@vpWidthF = 1.0 ;0.4
   res@gsnMaximize = True
   res@gsnPaperOrientation = "portrait"
   res@trYReverse = True
   res@lbBoxLinesOn = False
   time_axis_labels(time,res,restick)   
   res_back = res
;let's plot something to check the reading procedure
;see h_time_3.ncl example at
;http://ncl.ucar.edu/Applications/height_time.shtml
;http://ncl.ucar.edu/Applications/Scripts/h_time_3.ncl
   wks = gsn_open_wks("epsi","agcm_temp")
   gsn_define_colormap(wks,"rainbow")
   res@gsnLeftString = "(a) " + temp@long_name
   plot = gsn_csm_contour(wks,temp,res)

   wks = gsn_open_wks("epsi","agcm_umes")
   gsn_define_colormap(wks,"WhBlGrYeRe")
   res@gsnLeftString = "(b) " + umes@long_name
   plot = gsn_csm_contour(wks,umes,res)

;  gsn_define_colormap(wks,"BlRe")
   res@gsnSpreadColors = True

   wks = gsn_open_wks("epsi", "agcm_uvel")
   gsn_define_colormap(wks,"amwg_blueyellowred") ;"rainbow")
;  gsn_define_colormap(wks,"BlWhRe") ;"rainbow")
   symMinMaxPlt((/uvel,vvel/),24,False,res)
   res@gsnLeftString = "(c) " + uvel@long_name
   plot = gsn_csm_contour(wks,uvel,res)

   wks = gsn_open_wks("epsi", "agcm_vvel")
   gsn_define_colormap(wks,"amwg_blueyellowred")
;  gsn_define_colormap(wks,"BlWhRe") ;"rainbow")
   symMinMaxPlt((/uvel,vvel/),24,False,res)
   res@gsnLeftString = "(d) " + vvel@long_name
   plot = gsn_csm_contour(wks,vvel,res)

   delete(res)
   res = res_back

   wks = gsn_open_wks("epsi", "agcm_swrh")
;  gsn_define_colormap(wks,"BlWhRe") ;"WhBlGrYeRe")
   gsn_define_colormap(wks,"amwg_blueyellowred")
;  symMinMaxPlt((/swrh,lwrh/),24,False,res)
   res@gsnLeftString = "(e) " + swrh@long_name
   plot = gsn_csm_contour(wks,swrh,res)

   wks = gsn_open_wks("epsi", "agcm_lwrh")
;  gsn_define_colormap(wks,"BlWhRe") ;"WhBlGrYeRe")
   gsn_define_colormap(wks,"amwg_blueyellowred")
;  symMinMaxPlt((/swrh,lwrh/),24,False,res)
   res@gsnLeftString = "(f) " + lwrh@long_name
   plot = gsn_csm_contour(wks,lwrh,res)   

;saving data to a NetCDF file, method 1
;http://www.ncl.ucar.edu/Applications/method_1.shtml
   system("/bin/rm -f SEMIPROG_IN.nc")
   ncdf = addfile("SEMIPROG_IN.nc", "c")

   dimNames = (/"lev", "time"/)
   dimSizes = (/nz, nrec/)
   dimUnlim = (/False, False/)
   filedimdef(ncdf,dimNames,dimSizes,dimUnlim)

;  ncdf->Z = pres    ; coordinates
;  ncdf->T = time
   ncdf->PSLC = pslc ; surface variables
   ncdf->USST = usst
   ncdf->VSST = vsst
   ncdf->CSSF = cssf
   ncdf->CLSF = clsf
   ncdf->OCIS = ocis
   ncdf->OCES = oces
   ncdf->ISWF = iswf
   ncdf->ROCE = roce
   ncdf->olis = olis
   ncdf->OLES = oles
   ncdf->ROLE = role
   ncdf->SWTC = swtc
   ncdf->OCIC = ocic
   ncdf->LWTC = lwtc
   ncdf->LWBC = lwbc
   ncdf->TEMP = temp ; profiles
   ncdf->UMES = umes
;  ncdf->LIQM = liqm
;  ncdf->ICEM = icem
   ncdf->UVEL = uvel
   ncdf->VVEL = vvel
   ncdf->SWRH = swrh
   ncdf->LWRH = lwrh

end
