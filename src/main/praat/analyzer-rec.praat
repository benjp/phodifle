#######################################
# Author : Benjamin Paillereau        #
# benjamin.paillereau@exoplatform.com #
# last modified : May 21, 2009        #
# version : v0.12                     #
#######################################

#######################################
### FORM
#######################################
form Name
	word Identifiant .TextGrid
#	word Dossier /Users/benjamin/Documents/Perso/praat/sons_rms_decoupe_sl
	word Dossier /Users/benjamin/Documents/Perso/praat/olds/Q_slovaque_nettoye
	word Resultats /Users/benjamin/Desktop
	natural Tier_max 3
	choice Avec_rms 2
	              button Oui
	              button Non
	choice Sexe_du_locuteur 1
	              button féminin
	              button masculin                 
	choice Analyser_un_segment_precis 2
	  	button Oui
	   	button Non
	word Tier 1
#	comment rappel ...   ....   c++ pour consonnes ; v++ pour voyelles ; L++ pour sonantes  ...
#	word Analyser_quoi 
#	word Contexte_avant 
#	word Contexte_apres 
endform

#######################################
### MAIN PROGRAM
#######################################
clearinfo
printline Analyze started...
date$ = date$ ()
printline 'date$'

dir$ = "'Dossier$'"
dir_results$ = "'Resultats$'"
ident$ = "'Identifiant$'"
sex = 'Sexe_du_locuteur'
withRms = 'Avec_rms'
tier$ = "'Tier$'"
tierMax = 'Tier_max'
restrict = 'Analyser_un_segment_precis'
# OUTPUT
out1$ = dir_results$ + "/" + "results.xls"
out2$ = dir_results$ + "/" + "results_moy.xls"
out3$ = dir_results$ + "/" + "results-utf8.xls"
call proc_log_init

Create Strings as file list... liste 'dir$'/*'ident$'
Sort
lstSamples = selected("Strings")
nbSamples = Get number of strings
## DEBUG : LIMIT TO ONE FILE
# nbSamples = 2

call proc_moy_init

# Read every files in the source directory
for iSamples from 1 to nbSamples
	select 'lstSamples'
	sample$ = Get string... iSamples
	sample_short$ = sample$ - ident$
	sample$ = dir$ + "/" + sample_short$
	#printline 'sample$'
	
	if withRms = 1
		### READ RMS
		file$ = sample$ + "_rms.wav"
		Read from file... 'file$'
		sound_rms = selected("Sound")
		### READ PRAAT
		file$ = sample$ + ".praat"
		Read Strings from raw text file... 'file$'
		praat = selected("Strings")
	endif
	### READ WAV
	file$ = sample$ + ".wav"
	Read from file... 'file$'
	sound = selected("Sound")
	### READ TEXTGRID
	file$ = sample$ + ".TextGrid"
	Read from file... 'file$'
	textgrid = selected("TextGrid")
	
	### GET GENERAL VALUES
	percent = 0.2
	if withRms = 1
		select 'praat'
		rmsMoy = Get string... 1
		rmsVal = Get string... 2
	endif
	#Get formant by sex
	select 'sound'
	if sex = 2
		noprogress To Formant (burg)... 0.01 5 5000 0.025 50
	elsif sex = 1
		noprogress To Formant (burg)... 0.01 5 6000 0.025 50
	endif
	formant = selected("Formant")
	select 'sound'
	noprogress To Pitch... 0.01 75 600
	pitch = selected("Pitch")
		
	call proc_analyze
		
endfor

#call proc_moy_print

#system iconv -f UTF-16 -t UTF-8 'out1$' > 'out3$'

#system java -Dfile.encoding=UTF-8 -jar praat.jar 'out1$' 2 2

date$ = date$ ()
printline 'date$'
printline Results saved in 'dir_results$'
exit

#######################################
### ANALYZE
#######################################
procedure proc_analyze
	if restrict = 1
		call proc_restrict 'tier$'
	else
		select 'textgrid'
		.nbTiers = Get number of tiers
		if .nbTiers > tierMax
			.nbTiers = tierMax
		endif
		for .iTiers from 1 to .nbTiers
			call proc_restrict '.iTiers'
		endfor
	endif
endproc

#######################################
### RESTRICT BY TIER 
#######################################
procedure proc_restrict .tier
	printline Tier '.tier' analyze on 'sample_short$'
	select 'textgrid'
	.nbInt = Get number of intervals... .tier	
	.indexMax_'.tier' = 0
	for i from 1 to .nbInt
		select 'textgrid'
		.int$ = Get label of interval... .tier i
		if (.int$ <> "_" and .int$ <> "_ " and .int$ <> "1" and .int$ <> " " and .int$ <> "" and .int$ <> "###")
			.indexMax_'.tier' = .indexMax_'.tier' + 1
			.itemp = .indexMax_'.tier'
			.tab_'.tier'_'.itemp' = i
			.tabLabel_'.tier'_'i'$ = .int$			
			.startInt = Get starting point... .tier i
			.endInt = Get end point... .tier i
			
			### DURATION
			call proc_duration '.tier' 'i' '.startInt' '.endInt'
			.curDur = proc_duration.tab_'.tier'_'i'
			
#			if withRms = 1
#				### RMS
#				call proc_rms '.tier' 'i' '.startInt' '.endInt'
#			endif
			
			### F0
			call proc_fo '.tier' 'i' '.startInt' '.endInt'
			call proc_duration_from_subtier '.tier' 'i' '.startInt' '.endInt'
			
			if (proc_fo.tab_'.tier'_'i'_beg=undefined or proc_fo.tab_'.tier'_'i'_mid=undefined or proc_fo.tab_'.tier'_'i'_end=undefined)
				call proc_copy_from_subtier '.tier' 'i' '.startInt' '.endInt'
			endif
			
#			### GET VALUES FROM CHILD IF POSSIBLE
#			call proc_copy_from_subtier '.tier' 'i' '.startInt' '.endInt'
#			if proc_copy_from_subtier.copied = 0
#				if withRms = 1
#					### RMS
#					call proc_rms '.tier' 'i' '.startInt' '.endInt'
#				endif
#				### F0
#				### call proc_fo '.tier' 'i' '.startInt' '.endInt'
#			endif
			
			if withRms = 1
				.curRmsBeg$ = fixed$ ( proc_rms.tab_'.tier'_'i'_beg , 2 )
				.curRmsMid$ = fixed$ ( proc_rms.tab_'.tier'_'i'_mid , 2 )
				.curRmsEnd$ = fixed$ ( proc_rms.tab_'.tier'_'i'_end , 2 )
			elsif
				.curRmsBeg$ = 0
				.curRmsMid$ = 0
				.curRmsEnd$ = 0
			endif
			.curFoMean$ = fixed$ ( proc_fo.tab_'.tier'_'i'_mean , 0 )
			.curFoBeg$ = fixed$ ( proc_fo.tab_'.tier'_'i'_beg , 0 )
			.curFoMid$ = fixed$ ( proc_fo.tab_'.tier'_'i'_mid , 0 )
			.curFoEnd$ = fixed$ ( proc_fo.tab_'.tier'_'i'_end , 0 )
			

#			for .iformant from 1 to 5
#				### FORMANT 1 => 5
#				call proc_formant '.tier' 'i' '.startInt' '.endInt' '.iformant'
#				.curF_'.iformant'_mean$ = fixed$ ( proc_formant.tab_'.tier'_'i'_'.iformant'_mean , 0 )
#				.curF_'.iformant'_beg$ = fixed$ ( proc_formant.tab_'.tier'_'i'_'.iformant'_beg , 0 )
#				.curF_'.iformant'_mid$ = fixed$ ( proc_formant.tab_'.tier'_'i'_'.iformant'_mid , 0 )
#				.curF_'.iformant'_end$ = fixed$ ( proc_formant.tab_'.tier'_'i'_'.iformant'_end , 0 )
#				.curF_'.iformant'_bandwidth$ = fixed$ ( proc_formant.tab_'.tier'_'i'_'.iformant'_bandwidth , 0 )
#			endfor
			
			if restrict = 1
				call proc_canvas '.int$' '.curF_1_mean$' '.curF_2_mean$'
			endif
			
			if (.tier = 2 and restrict <> 1)
				.curDur1$ = fixed$ ( proc_duration.tab_'.tier'_'i'_1 , 0 )
				.curDur2$ = fixed$ ( proc_duration.tab_'.tier'_'i'_2 , 0 )
			else
				.curDur1$ = "_"
				.curDur2$ = "_"
			endif
			
			if .tier = 2
				call proc_calc_moy '.int$' 1 .curDur
				call proc_add_value proc_calc_moy.row 2 proc_duration.tab_'.tier'_'i'_1
				call proc_add_value proc_calc_moy.row 3 proc_duration.tab_'.tier'_'i'_2
				if withRms = 1
					if (proc_rms.tab_'.tier'_'i'_beg<>undefined and proc_rms.tab_'.tier'_'i'_mid<>undefined and proc_rms.tab_'.tier'_'i'_end<>undefined)
						call proc_add_value proc_calc_moy.row 4 proc_rms.tab_'.tier'_'i'_beg
						call proc_add_value proc_calc_moy.row 5 proc_rms.tab_'.tier'_'i'_mid
						call proc_add_value proc_calc_moy.row 6 proc_rms.tab_'.tier'_'i'_end
					endif
				endif
				if (proc_fo.tab_'.tier'_'i'_mean<>undefined and proc_fo.tab_'.tier'_'i'_beg<>undefined and proc_fo.tab_'.tier'_'i'_mid<>undefined and proc_fo.tab_'.tier'_'i'_end<>undefined)
					call proc_add_value proc_calc_moy.row 7 proc_fo.tab_'.tier'_'i'_mean
					call proc_add_value proc_calc_moy.row 8 proc_fo.tab_'.tier'_'i'_beg
					call proc_add_value proc_calc_moy.row 9 proc_fo.tab_'.tier'_'i'_mid
					call proc_add_value proc_calc_moy.row 10 proc_fo.tab_'.tier'_'i'_end
				endif
			endif
			
			### LOG RESULTS		
			call proc_log '.tier' "'.int$'" '.startInt' '.curDur' '.curDur1$' '.curDur2$' '.curRmsBeg$' '.curRmsMid$' '.curRmsEnd$' '.curFoMean$' '.curFoBeg$' '.curFoMid$' '.curFoEnd$'
#			call proc_log_formant '.curF_1_mean$' '.curF_1_beg$' '.curF_1_mid$' '.curF_1_end$' '.curF_1_bandwidth$'
#			call proc_log_formant '.curF_2_mean$' '.curF_2_beg$' '.curF_2_mid$' '.curF_2_end$' '.curF_2_bandwidth$'
#			call proc_log_formant '.curF_3_mean$' '.curF_3_beg$' '.curF_3_mid$' '.curF_3_end$' '.curF_3_bandwidth$'
#			call proc_log_formant '.curF_4_mean$' '.curF_4_beg$' '.curF_4_mid$' '.curF_4_end$' '.curF_4_bandwidth$'
#			call proc_log_formant '.curF_5_mean$' '.curF_5_beg$' '.curF_5_mid$' '.curF_5_end$' '.curF_5_bandwidth$'
			
		endif
	endfor
endproc

#######################################
### INIT MOY
#######################################
procedure proc_moy_init
	moy_data$ = "tab_moy"
	moy_cpt$ = "tab_moy_cpt"
	moy_cols = 10
	# Create a table for the duration
	Create TableOfReal... moy_data$ 1 moy_cols
	idmoydata = selected ("TableOfReal",-1)
	Create TableOfReal... moy_cpt$ 1 moy_cols
	idmoycpt = selected ("TableOfReal",-1)
endproc

#######################################
### CALC MOY FOR TIER,INT => .tab[tier][inter]
#######################################
procedure proc_calc_moy .label$ .col .value
	call proc_moy_get_row '.label$'
	.row = proc_moy_get_row.ok
	if .value <> undefined
		call proc_add_value '.row' '.col' '.value'
	endif
endproc

procedure proc_add_value .row .col .value
	if .value <> undefined
		select idmoydata
		.data = Get value... .row .col
		.data = .data + .value
		Set value... .row .col .data
		call proc_inc_cpt '.row' '.col'
	endif
endproc

procedure proc_inc_cpt .row .col
	select idmoycpt
	.data = Get value... .row .col
	.data = .data + 1
	Set value... .row .col .data
endproc

procedure proc_moy_get_row .label$
	select idmoydata
	.rownb = Get number of rows
	.irow = 1
	.ok = -1
	repeat
		.rowname$ = Get row label... .irow
		if .rowname$ = .label$
			.ok = .irow
		endif
		.irow = .irow + 1
	until (.irow>.rownb or .ok>0)
	if .ok = -1
		select idmoydata
		Insert row (index)... .irow
		Set row label (index)... .irow '.label$'
		for .col to moy_cols
			Set value... .irow .col 0
		endfor
		.ok = .irow
		select idmoycpt
		Insert row (index)... .irow
		for .col to moy_cols
			Set value... .irow .col 0
		endfor
	endif
endproc

procedure proc_moy_print
	select idmoydata
	.rownb = Get number of rows
	for .row from 2 to .rownb
		select idmoydata
		.label$ = Get row label... .row
		call proc_log_moy '.label$'
		for .col to moy_cols
			select idmoydata
			.val = Get value... .row .col
			select idmoycpt
			.cpt = Get value... .row .col
			.str$ = "=" + "'.val:2'" + "/" + "'.cpt'"
			.str$ = replace$ (.str$, ".", ",", 0)
			call proc_log_moy_plus '.str$'
		endfor
	endfor
endproc

#######################################
### COPY FROM SUB TIER BY TIER,INT => .tab[tier][inter]
#######################################
procedure proc_duration_from_subtier .tier .inter .startInt .endInt
	.beg = .startInt + percent*(.endInt - .startInt)
	.end = .endInt - percent*(.endInt - .startInt)
	if (.tier = 2 and restrict <> 1)
		## TODO : works only with syllable based on 2 phonems, we should improve this later
		.tierSub = .tier - 1
		select 'textgrid'
		.interSubBeg = Get interval at time... .tierSub .beg
		.interSubEnd = Get interval at time... .tierSub .end
		proc_duration.tab_'.tier'_'.inter'_1 = proc_duration.tab_'.tierSub'_'.interSubBeg'
		proc_duration.tab_'.tier'_'.inter'_2 = proc_duration.tab_'.tierSub'_'.interSubEnd'
	endif
endproc

#######################################
### COPY FROM SUB TIER BY TIER,INT => .tab[tier][inter]
#######################################
procedure proc_copy_from_subtier .tier .inter .startInt .endInt
	.copied = 0
	.beg = .startInt + percent/2*(.endInt - .startInt)
	.end = .endInt - percent/2*(.endInt - .startInt)
	if (.tier = 2 and restrict <> 1)
		## TODO : works only with syllable based on 2 phonems, we should improve this later
		.tierSub = .tier - 1
		select 'textgrid'
		.interSubBeg = Get interval at time... .tierSub .beg
		.interSubEnd = Get interval at time... .tierSub .end
#		proc_duration.tab_'.tier'_'.inter'_1 = proc_duration.tab_'.tierSub'_'.interSubBeg'
#		proc_duration.tab_'.tier'_'.inter'_2 = proc_duration.tab_'.tierSub'_'.interSubEnd'
		.begSubBeg = proc_fo.tab_'.tierSub'_'.interSubBeg'_beg
		.midSubBeg = proc_fo.tab_'.tierSub'_'.interSubBeg'_mid
		.endSubBeg = proc_fo.tab_'.tierSub'_'.interSubBeg'_end
		.begSubEnd = proc_fo.tab_'.tierSub'_'.interSubEnd'_beg
		.midSubEnd = proc_fo.tab_'.tierSub'_'.interSubEnd'_mid
		.endSubEnd = proc_fo.tab_'.tierSub'_'.interSubEnd'_end
		
#		printline SUB inter:'.inter' start:'.startInt' 
#		printline SUB    ::: FO beg:'.begSubBeg' mid:'.midSubBeg' end:'.endSubBeg'
#		printline SUB    ::: FO beg:'.begSubEnd' mid:'.midSubEnd' end:'.endSubEnd'
		
		
#		.meanSubEnd = proc_fo.tab_'.tierSub'_'.interSubEnd'_mean
 		if ( .begSubBeg = undefined or .midSubBeg = undefined or .endSubBeg = undefined)
 			if withRms = 1
				proc_rms.tab_'.tier'_'.inter'_beg = proc_rms.tab_'.tierSub'_'.interSubEnd'_beg
				proc_rms.tab_'.tier'_'.inter'_mid = proc_rms.tab_'.tierSub'_'.interSubEnd'_mid
				proc_rms.tab_'.tier'_'.inter'_end = proc_rms.tab_'.tierSub'_'.interSubEnd'_end
			endif
			proc_fo.tab_'.tier'_'.inter'_mean = proc_fo.tab_'.tierSub'_'.interSubEnd'_mean
			proc_fo.tab_'.tier'_'.inter'_beg = proc_fo.tab_'.tierSub'_'.interSubEnd'_beg
			proc_fo.tab_'.tier'_'.inter'_mid = proc_fo.tab_'.tierSub'_'.interSubEnd'_mid
			proc_fo.tab_'.tier'_'.inter'_end = proc_fo.tab_'.tierSub'_'.interSubEnd'_end
			.copied = 1
 		elsif ( .begSubEnd = undefined or .midSubEnd = undefined or .endSubEnd = undefined)
#		elsif .meanSubEnd = undefined
 			if withRms = 1
				proc_rms.tab_'.tier'_'.inter'_beg = proc_rms.tab_'.tierSub'_'.interSubBeg'_beg
				proc_rms.tab_'.tier'_'.inter'_mid = proc_rms.tab_'.tierSub'_'.interSubBeg'_mid
				proc_rms.tab_'.tier'_'.inter'_end = proc_rms.tab_'.tierSub'_'.interSubBeg'_end
			endif
			proc_fo.tab_'.tier'_'.inter'_mean = proc_fo.tab_'.tierSub'_'.interSubBeg'_mean
			proc_fo.tab_'.tier'_'.inter'_beg = proc_fo.tab_'.tierSub'_'.interSubBeg'_beg
			proc_fo.tab_'.tier'_'.inter'_mid = proc_fo.tab_'.tierSub'_'.interSubBeg'_mid
			proc_fo.tab_'.tier'_'.inter'_end = proc_fo.tab_'.tierSub'_'.interSubBeg'_end
			.copied = 1
		endif
		.begBeg = proc_fo.tab_'.tier'_'.inter'_beg
		.midBeg = proc_fo.tab_'.tier'_'.inter'_mid
		.endBeg = proc_fo.tab_'.tier'_'.inter'_end
#		printline SUB_RES::: FO beg:'.begBeg' mid:'.midBeg' end:'.endBeg'
	endif	
endproc

#######################################
### DURATION BY TIER,INT => .tab[tier][inter]
#######################################
procedure proc_duration .tier .inter .startInt .endInt
	.durInt = round((.endInt - .startInt)*1000)
	.tab_'.tier'_'.inter' = .durInt
endproc

#######################################
### RMS BY TIER,INT => .tab[tier][inter](beg,mid,end)
#######################################
procedure proc_rms .tier .inter .startInt .endInt
	.mid = (.startInt + .endInt)/2
	.beg = .startInt + percent*(.endInt - .startInt)
	.end = .endInt - percent*(.endInt - .startInt)

	select 'sound_rms'
	.begRms = Get value at time... Average .beg Sinc70
	.begRms = rmsVal + 20*log10(.begRms/rmsMoy)
	.midRms = Get value at time... Average .mid Sinc70
	.midRms = rmsVal + 20*log10(.midRms/rmsMoy)
	.endRms = Get value at time... Average .end Sinc70
	.endRms = rmsVal + 20*log10(.endRms/rmsMoy)

	.tab_'.tier'_'.inter'_beg = .begRms
	.tab_'.tier'_'.inter'_mid = .midRms
	.tab_'.tier'_'.inter'_end = .endRms
endproc

#######################################
### F0 BY TIER,INT => .tab[tier][inter](mean,beg,mid,end)
#######################################
procedure proc_fo .tier .inter .startInt .endInt
	.mid = (.startInt + .endInt)/2
	.beg = .startInt + percent*(.endInt - .startInt)
	.end = .endInt - percent*(.endInt - .startInt)

	select 'pitch'
	.meanFo = Get mean... '.beg' '.end' Hertz
	.meanFo = round(.meanFo)
	.begFo = Get value at time... .beg Hertz Linear
	.begFo = round(.begFo)
	.midFo = Get value at time... .mid Hertz Linear
	.midFo = round(.midFo)
	.endFo = Get value at time... .end Hertz Linear
	.endFo = round(.endFo)

#	printline inter:'.inter' start:'.startInt' beg:'.beg' mid:'.mid' end:'.end' ::: FO beg:'.begFo' mid:'.midFo' end:'.endFo'
	
	.tab_'.tier'_'.inter'_mean = .meanFo
	.tab_'.tier'_'.inter'_beg = .begFo
	.tab_'.tier'_'.inter'_mid = .midFo
	.tab_'.tier'_'.inter'_end = .endFo
endproc

#######################################
### FORMANT BY TIER,INT => .tab[tier][inter][formant](mean,beg,mid,end,bandwidth)
#######################################
procedure proc_formant .tier .inter .startInt .endInt .formant
	.mid = (.startInt + .endInt)/2
	.beg = .startInt + percent*(.endInt - .startInt)
	.end = .endInt - percent*(.endInt - .startInt)

	select 'formant'
	.meanFo = Get mean... '.formant' '.beg' '.end' Hertz
	.meanFo = round(.meanFo)
	.begFo = Get value at time... '.formant' .beg Hertz Linear
	.begFo = round(.begFo)
	.midFo = Get value at time... '.formant' .mid Hertz Linear
	.midFo = round(.midFo)
	.endFo = Get value at time... '.formant' .end Hertz Linear
	.endFo = round(.endFo)
	.bandwidth = Get bandwidth at time... '.formant' .mid Hertz Linear
	.bandwidth = round (.bandwidth)

	.tab_'.tier'_'.inter'_'.formant'_mean = .meanFo
	.tab_'.tier'_'.inter'_'.formant'_beg = .begFo
	.tab_'.tier'_'.inter'_'.formant'_mid = .midFo
	.tab_'.tier'_'.inter'_'.formant'_end = .endFo
	.tab_'.tier'_'.inter'_'.formant'_bandwidth = .bandwidth
endproc

#######################################
### CANVAS
#######################################
procedure proc_canvas .label$ .meanF1 .meanF2
	Viewport... 0 6 6.5 9
	Font size... 18
	Line width... 1
	Viewport... 0 6 0 6
	Axes... 100 900 600 2900
	Text top... yes Formant chart
	Text bottom... yes F_1 (Hz)
	Text left... yes F_2 (Hz)
	Font size... 14
	Marks bottom every... 1 100 yes yes yes
	Marks left every... 1 500 yes yes yes
	Plain line
	Viewport... 0 6 0 6	
	Draw circle... .meanF1 .meanF2 27
	Text... .meanF1 Centre .meanF2 Half '.label$'
endproc

#######################################
### LOG PROCS
#######################################
procedure proc_log_init
	filedelete 'out1$'
	filedelete 'out2$'
	fileappend "'out2$'" Label 'tab$' Duration 'tab$' Duration P1 'tab$' Duration P2 'tab$' RMS beg 'tab$' RMS mid 'tab$' RMS end 'tab$' F0 Mean 'tab$' F0 Beg 'tab$' F0 Mid 'tab$' F0 End
	out1i = 0
	fileappend "'out1$'" Index 'tab$' File 'tab$' Tier 'tab$' Label 'tab$' Start 'tab$' Duration 'tab$' Duration P1 'tab$' Duration P2 'tab$' RMS Beg 'tab$' RMS Mid 'tab$' RMS End 'tab$' F0 Mean 'tab$' F0 Beg 'tab$' F0 Mid 'tab$' F0 End
	fileappend "'out1$'" 'tab$' F1 Mean 'tab$' F1 Beg 'tab$' F1 Mid 'tab$' F1 End 'tab$' F1 Bandwidth
	fileappend "'out1$'" 'tab$' F2 Mean 'tab$' F2 Beg 'tab$' F2 Mid 'tab$' F2 End 'tab$' F2 Bandwidth
	fileappend "'out1$'" 'tab$' F3 Mean 'tab$' F3 Beg 'tab$' F3 Mid 'tab$' F3 End 'tab$' F3 Bandwidth
	fileappend "'out1$'" 'tab$' F4 Mean 'tab$' F4 Beg 'tab$' F4 Mid 'tab$' F4 End 'tab$' F4 Bandwidth
	fileappend "'out1$'" 'tab$' F5 Mean 'tab$' F5 Beg 'tab$' F5 Mid 'tab$' F5 End 'tab$' F5 Bandwidth
endproc

procedure proc_log .tier .label$ .start .dur .dur1$ .dur2$ .rmsBeg$ .rmsMid$ .rmsEnd$ .foMean$ .foBeg$ .foMid$ .foEnd$
	out1i = out1i + 1
	fileappend "'out1$'" 'newline$''out1i' 'tab$' 'sample_short$' 'tab$' '.tier' 'tab$' '.label$' 'tab$' '.start' 'tab$' '.dur' 'tab$' '.dur1$' 'tab$' '.dur2$' 'tab$' '.rmsBeg$' 'tab$' '.rmsMid$' 'tab$' '.rmsEnd$' 'tab$' '.foMean$' 'tab$' '.foBeg$' 'tab$' '.foMid$' 'tab$' '.foEnd$'
endproc

procedure proc_log_formant .mean$ .beg$ .mid$ .end$ .band$
	fileappend "'out1$'" 'tab$' '.mean$' 'tab$' '.beg$' 'tab$' '.mid$' 'tab$' '.end$' 'tab$' '.band$'
endproc

procedure proc_log_moy .label$
	fileappend "'out2$'" 'newline$''.label$'
endproc

procedure proc_log_moy_plus .val$
	fileappend "'out2$'" 'tab$''.val$'
endproc