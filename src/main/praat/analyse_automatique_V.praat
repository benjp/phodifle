form Name
comment Speaker?
sentence Locuteur
# comment Number of repetition?
# integer repetition 1
sentence Path /Users/benjamin/Public/results/
choice Sexe_du_locuteur 2
                button féminin
                button masculin                 
word Voyelles_avec_formants_proches uoOiy

comment Vowel symbol appears at the beginning (e.g. "i_01") or at the end (e.g. "01_i")?
choice left_right 2
    button beginning
    button end
comment Include nasal vowels?
choice v_nasales 2
    button yes
    button no
choice analyser_un_segment_precis 2
  	 button Oui
   button Non
comment rappel ...   ....   c++ pour consonnes ; v++ pour voyelles ; L++ pour sonantes  ...
word analyser_quoi 
word contexte_avant 
word contexte_apres 
endform

clearinfo
quote$ = "'"
# path$ = "/Users/takeki/Documents/data/traitement_du_signal/Praat/Praat_savoir_faire/Praat_programming/"
sound = selected("Sound")
textgrid = selected("TextGrid")

if sexe_du_locuteur = 2
	sexe_du_loc$ = "m" 
	highf = 5000
elsif sexe_du_locuteur = 1
	sexe_du_loc$ = "f"
	highf = 6000
endif

# Generates formants for non close vowels
select 'sound'
To Formant (burg)... 0.01 5 highf 0.025 50       
formant = selected("Formant")
# Generates formants for close vowels
highf = highf - 1000
select 'sound'
To Formant (burg)... 0.01 5 highf 0.025 50
formant_close = selected("Formant")


select 'sound'
To Intensity... 60 0
intensity = selected("Intensity")
select 'textgrid'
outputfile1$ = path$ + "duree.xls"
outputfile2$ = path$ + "formants.xls"
outputfile3$ = path$ + "intensite.xls"
outputfile4$ = path$ + "Fo.xls"	
			
fileappend "'outputfile1$'" 'Name_of_selection$''tab$' 'newline$'Duration Tier 1'newline$'
fileappend "'outputfile2$'" Speaker 'tab$'Sex 'tab$'Repetition 'tab$'Vowel ID 'tab$'Segment 'tab$'Duration (ms) 'tab$'Position 'tab$'mean f0 (Hz) 'tab$'F1 (Hz) 'tab$'F2 (Hz) 'tab$'F3 (Hz) 'tab$'F4 (Hz) 'tab$'F5 (Hz) 'tab$'bandw1 (at midpoint) 'tab$'bandw2 'tab$'bandw3 'tab$'bandw4 'tab$'bandw5 'tab$' 'newline$'
fileappend "'outputfile3$'" 'tab$' 'Name_of_selection'. 'newline$'Intensity Tier 1'newline$'
fileappend "'outputfile4$'" 'tab$''Name_of_selection' 'newline$''newline$''tab$'Fo Tier 1'newline$' phonème 'tab$' mean Fo 'tab$' 'tab$' beg Fo 'tab$' 'tab$' mid Fo 'tab$' 'tab$' end Fo 'newline$'

select 'textgrid'

#-------------------------------------------
if analyser_un_segment_precis = 2

nb = Get number of tiers
	if nb = 1
call  comptage1
call intensite1
call intonation1
call duration1
call formant
	
	elsif nb = 2
call  comptage1
call  comptage2
call intensite1
call intensite2
call intonation1
call intonation2

	elsif nb = 3
call  comptage1
call  comptage2
call  comptage3
call intensite1
call intensite2
call intensite3
call intonation1
call intonation2
call intonation3
	endif

elsif analyser_un_segment_precis = 1

contexte0 = length(contexte_avant$)
contexte1 = length(contexte_apres$)

if (contexte0 = 0 and contexte1 = 0)
call cas1
elsif (contexte0 = 0 and contexte1 > 0)
call cas3
elsif (contexte0 > 0 and contexte1 = 0)
call cas2
elsif (contexte0 > 0 and contexte1 > 0)
call cas4
endif

procedure cas1

nb = Get number of tiers
	if nb = 1
call  comptage1bis
call duration1
call intensite1
call intonation1
call formant
	
	elsif nb = 2
call  comptage1bis
call duration1
call intensite1
call intonation1
call formant

	elsif nb = 3
call  comptage1bis
call duration1
call intensite1
call intonation1
call formant
	endif

endproc

procedure cas2
nb = Get number of tiers
	if nb = 1
call  comptage1ter
call duration1
call intensite1
call intonation1
call formant
	elsif nb = 2
call  comptage1ter
call duration1
call intensite1
call intonation1
call formant
	elsif nb = 3
call  comptage1ter
call duration1
call intensite1
call intonation1
call formant
	endif
endproc

procedure cas3
nb = Get number of tiers
	if nb = 1
call  comptage1quar
call duration1
call intensite1
call intonation1
call formant
	elsif nb = 2
call  comptage1quar
call duration1
call intensite1
call intonation1
call formant

	elsif nb = 3
call  comptage1quar
call duration1
call intensite1
call intonation1
call formant
	endif
endproc

procedure cas4
nb = Get number of tiers
	if nb = 1
call  comptage1quint
call duration1
call intensite1
call intonation1
call formant
	elsif nb = 2
call  comptage1quint
call duration1
call intensite1
call intonation1
call formant
	elsif nb = 3
call  comptage1quint
call duration1
call intensite1
call intonation1
call formant
	endif
endproc

endif
#----------------------------------
procedure comptage1

noiist = Get number of intervals... 1
nos = 0
for j from 1 to noiist

syllable$ = Get label of interval... 1 j
if (syllable$ <> "_" and syllable$ <> "_ " and syllable$ <> "1"and syllable$ <> " " and syllable$ <> "")

nos = nos + 1
syllable'nos' = j
endif
endfor

endproc

#-----------------------------------
procedure comptage2

noiseq = Get number of intervals... 2
noseq = 0
for j from 1 to noiseq
seq$ = Get label of interval... 2 j
if (seq$ <> "_" and seq$ <> "_ " and seq$ <> "1" and seq$ <> " " and seq$ <> "")

noseq = noseq + 1
seq'noseq' = j
endif
endfor			
	
endproc

#----------------------------------
procedure comptage3

noithird = Get number of intervals... 3
nothird = 0
for j from 1 to noithird
mot$ = Get label of interval... 3 j
if (mot$ <> "_" and mot$ <> "_ " and mot$ <> "1" and mot$ <> " " and mot$ <> "")

nothird = nothird + 1
mot'nothird' = j
endif
endfor

endproc

#---------------------------------
procedure duration1
	
select 'textgrid'

for l from 1 to nos
current_syllable = syllable'l'
label$ = Get label of interval... 1 current_syllable
				
start_syllable = Get starting point... 1 current_syllable
end_syllable = Get end point... 1 current_syllable
syllable_duration = round((end_syllable - start_syllable)*1000)
							
fileappend "'outputfile1$'" ('label$') 'tab$' 'syllable_duration'  'newline$'
endfor
endproc

#--------------------------------
procedure duration2

fileappend "'outputfile1$'" 'tab$' 'newline$' 'newline$' 'tab$'Duration tier 2 'newline$' 
for l from 1 to noseq
current_seq = seq'l'
label2$ = Get label of interval... 2 current_seq
					
start_seq = Get starting point... 2 current_seq
end_seq = Get end point... 2 current_seq
seq_duration = round((end_seq - start_seq)*1000)
							
fileappend "'outputfile1$'" ('label2$') 'tab$' 'seq_duration'  'newline$'
endfor
endproc

	
#-------------------------------------
procedure duration3

fileappend "'outputfile1$'" 'newline$''newline$' 'tab$'Duration tier 3 'newline$' 

for l from 1 to nothird
current_mot = mot'l'
label3$ = Get label of interval... 3 current_mot

start_mot = Get starting point... 3 current_mot
end_mot = Get end point... 3 current_mot
mot_duration = round((end_mot - start_mot)*1000)
							
fileappend "'outputfile1$'" ('label3$') 'tab$' 'mot_duration'  'newline$'
endfor
fileappend "'outputfile1$'" 'newline$'

endproc

#-------------------------------
procedure formant

count_01_i = 0
count_02_e = 0
count_03_e = 0
count_04_a = 0
count_05_o = 0
count_06_o = 0
count_07_u = 0
count_08_y = 0
count_09_2 = 0
count_10_9 = 0
count_11_en = 0
count_12_an = 0
count_13_on = 0
		
for l from 1 to nos
select 'textgrid'
current_syllable = syllable'l'
label$ = Get label of interval... 1 current_syllable

# extract the vowel symbol in SAMPA
if left_right = 2
	vowel$ = right$ (label$, 1)
	if vowel$ = "~"
		vowel$ = right$ (label$, 2)
	endif
else
	vowel$ = left$ (label$, 1)
	if vowel$ = "e" or vowel$ = "E" or vowel$ = "a" or vowel$ = "A" or vowel$ = "o" or vowel$ = "O"
		nasal$ = left$ (label$, 2)
		if nasal$ = "~"
			vowel$ = left$ (label$, 2)
		endif
	endif
endif


# attribute vowel ID and count occurrence
if vowel$ = "i"
	vowel_ID = 1
	count_01_i = count_01_i + 1
	count_rep = count_01_i
elsif vowel$ = "e"
	vowel_ID = 2
	count_02_e = count_02_e + 1
	count_rep = count_02_e
elsif vowel$ = "E"
	vowel_ID = 3
	count_03_e = count_03_e + 1
	count_rep = count_03_e
elsif vowel$ = "a"
	vowel_ID = 4
	count_04_a = count_04_a + 1
	count_rep = count_04_a
elsif vowel$ = "O"
	vowel_ID = 5
	count_05_o = count_05_o + 1
	count_rep = count_05_o
elsif vowel$ = "o"
	vowel_ID = 6
	count_06_o = count_06_o + 1
	count_rep = count_06_o
elsif vowel$ = "u"
	vowel_ID = 7
	count_07_u = count_07_u + 1
	count_rep = count_07_u
elsif vowel$ = "y"
	vowel_ID = 8
	count_08_y = count_08_y + 1
	count_rep = count_08_y
elsif vowel$ = "2"
	vowel_ID = 9
	count_09_2 = count_09_2 + 1
	count_rep = count_09_2
elsif vowel$ = "9"
	vowel_ID = 10
	count_10_9 = count_10_9 + 1
	count_rep = count_10_9
elsif vowel$ = "e~" or vowel$ = "E~"
	if v_nasales = 2
		vowel$ = "_"
	else
		vowel$ = "e~"
		vowel_ID = 11
		count_11_en = count_11_en + 1
		count_rep = count_11_en
	endif
elsif vowel$ = "a~" or vowel$ = "A~"
	if v_nasales = 2
		vowel$ = "_"
	else
		vowel$ = "a~"
		vowel_ID = 12
		count_12_an = count_12_an + 1
		count_rep = count_12_an
	endif
elsif vowel$ = "o~" or vowel$ = "O~"
	if v_nasales = 2
		vowel$ = "_"
	else
		vowel$ = "o~"
		vowel_ID = 13
		count_13_on = count_13_on + 1
		count_rep = count_13_on
	endif
elsif vowel$ = "@"
	vowel_ID = 14
	count_14_sch = count_14_sch + 1
	count_rep = count_14_sch
endif

# analysis is carried out if the segment contains a vowel
if vowel$ = "i" or vowel$ = "e" or vowel$ = "E" or vowel$ = "a" or vowel$ = "O" or vowel$ = "o" or vowel$ = "u" or vowel$ = "y" or vowel$ = "2" or vowel$ = "9" or vowel$ = "@" or vowel$ = "e~" or vowel$ = "o~" or vowel$ = "a~"

#-------subprocedure-------#		
start_syllable = Get starting point... 1 current_syllable
end_syllable = Get end point... 1 current_syllable
midpt = (start_syllable + end_syllable)/2
third_1 = (end_syllable - start_syllable)/3 + start_syllable
third_2 = end_syllable - (end_syllable - start_syllable)/3 
beg = start_syllable + 0.003
end = end_syllable - 0.003
dur_syll = round ((end_syllable - start_syllable) * 1000)

# Max Formant Analysis
select 'formant'
# Seach Close Voyel 
len = length(voyelles_avec_formants_proches$)
for i from 1 to len
	voy$ = mid$ ( voyelles_avec_formants_proches$, 'i', 1)
	if voy$ = vowel$
	    #printline Close Voyel : 'vowel$'
		select 'formant_close'
	endif
endfor

mean_f1 = Get mean... 1 'start_syllable' 'end_syllable' Hertz
mean_f1 = round (mean_f1)	
		
beg_f1 = Get mean... 1 'start_syllable' 'third_1' Hertz
beg_f1 = round (beg_f1)	

mid_f1 = Get mean... 1 'third_1' 'third_2' Hertz
mid_f1 = round (mid_f1)
	
end_f1 = Get mean... 1 'third_2' 'end_syllable' Hertz
end_f1 = round (end_f1)

bandwidth1 = Get bandwidth at time... 1 midpt Hertz Linear
bandwidth1 = round (bandwidth1)

#fileappend "'outputfile2$'" ('label$') 'tab$' 'mean_f1' 'tab$' 'beg_f1'  'tab$' 'mid_f1' 'tab$' 'end_f1' 'tab$' 'tab$' 'bandwidth1' 'tab$''tab$'


mean_f2 = Get mean... 2 'start_syllable' 'end_syllable' Hertz
mean_f2 = round (mean_f2)	

beg_f2 = Get mean... 2 'start_syllable' 'third_1' Hertz
beg_f2 = round (beg_f2)	

mid_f2 = Get mean... 2 'third_1' 'third_2' Hertz
mid_f2 = round (mid_f2)	

end_f2 = Get mean... 2 'third_2' 'end_syllable' Hertz
end_f2 = round (end_f2)	

bandwidth2 = Get bandwidth at time... 2 midpt Hertz Linear
bandwidth2 = round (bandwidth2)

change_f2 = end_f2 / beg_f2

#fileappend "'outputfile2$'" 'mean_f2' 'tab$' 'beg_f2'  'tab$' 'mid_f2' 'tab$' 'end_f2' 'tab$' 'tab$' 'bandwidth2' 'tab$' 'change_f2' 'tab$''tab$'


mean_f3 = Get mean... 3 'start_syllable' 'end_syllable' Hertz
mean_f3 = round (mean_f3)

beg_f3 = Get mean... 3 'start_syllable' 'third_1' Hertz
beg_f3 = round (beg_f3)

mid_f3 = Get mean... 3 'third_1' 'third_2' Hertz
mid_f3 = round (mid_f3)

end_f3 = Get mean... 3 'third_2' 'end_syllable' Hertz
end_f3 = round (end_f3)

bandwidth3 = Get bandwidth at time... 3 midpt Hertz Linear
bandwidth3 = round (bandwidth3)

#fileappend "'outputfile2$'" 'mean_f3' 'tab$' 'beg_f3'  'tab$' 'mid_f3' 'tab$' 'end_f3' 'tab$' 'tab$' 'bandwidth3' 'tab$' 'tab$'


mean_f4 = Get mean... 4 'start_syllable' 'end_syllable' Hertz
mean_f4 = round (mean_f4)	

beg_f4 = Get mean... 4 'start_syllable' 'third_1' Hertz
beg_f4 = round (beg_f4)	

mid_f4 = Get mean... 4 'third_1' 'third_2' Hertz
mid_f4 = round (mid_f4)	

end_f4 = Get mean... 4 'third_2' 'end_syllable' Hertz
end_f4 = round (end_f4)	

bandwidth4 = Get bandwidth at time... 4 midpt Hertz Linear
bandwidth4 = round (bandwidth4)

#fileappend "'outputfile2$'" 'mean_f4' 'tab$' 'beg_f4'  'tab$' 'mid_f4' 'tab$' 'end_f4' 'tab$' 'tab$' 'bandwidth4' 'tab$''tab$'

mean_f5 = Get mean... 5 'start_syllable' 'end_syllable' Hertz
mean_f5 = round (mean_f5)	

beg_f5 = Get mean... 5 'start_syllable' 'third_1' Hertz
beg_f5 = round (beg_f5)	

mid_f5 = Get mean... 5 'third_1' 'third_2' Hertz
mid_f5 = round (mid_f5)	

end_f5 = Get mean... 5 'third_2' 'end_syllable' Hertz
end_f5 = round (end_f5)	

bandwidth5 = Get bandwidth at time... 5 midpt Hertz Linear
bandwidth5 = round (bandwidth5)

# add F0 info
select 'pitch'	
		 						
mean_Fo = Get mean... 'start_syllable' 'end_syllable' Hertz
mean_Fo = round (mean_Fo)	
beg_Fo = Get mean... 'start_syllable' 'third_1' Hertz
beg_Fo = round (beg_Fo)	
mid_Fo = Get mean... 'third_1' 'third_2' Hertz
mid_Fo = round (mid_Fo)	
end_Fo = Get mean... 'third_2' 'end_syllable' Hertz
end_Fo = round (end_Fo)	

#fileappend "'outputfile2$'" 'mean_f5' 'tab$' 'beg_f5'  'tab$' 'mid_f5' 'tab$' 'end_f5' 'tab$' 'tab$' 'bandwidth5' 'newline$'

fileappend "'outputfile2$'" 'locuteur$''tab$''sexe_du_loc$' 'tab$''count_rep' 'tab$''vowel_ID' 'tab$''vowel$' 'tab$' 'tab$'1_beg 'tab$''beg_Fo' 'tab$''beg_f1' 'tab$''beg_f2' 'tab$''beg_f3' 'tab$''beg_f4' 'tab$''beg_f5' 'tab$' 'tab$' 'tab$' 'tab$' 'tab$' 'tab$' 'newline$'
fileappend "'outputfile2$'" 'locuteur$''tab$''sexe_du_loc$' 'tab$''count_rep' 'tab$''vowel_ID' 'tab$''vowel$' 'tab$' 'tab$'2_mid 'tab$''mid_Fo' 'tab$''mid_f1' 'tab$''mid_f2' 'tab$''mid_f3' 'tab$''mid_f4' 'tab$''mid_f5' 'tab$' 'tab$' 'tab$' 'tab$' 'tab$' 'tab$' 'newline$'
fileappend "'outputfile2$'" 'locuteur$''tab$''sexe_du_loc$' 'tab$''count_rep' 'tab$''vowel_ID' 'tab$''vowel$' 'tab$' 'tab$'3_end 'tab$''end_Fo' 'tab$''end_f1' 'tab$''end_f2' 'tab$''end_f3' 'tab$''end_f4' 'tab$''end_f5' 'tab$' 'tab$' 'tab$' 'tab$' 'tab$' 'tab$' 'newline$'
fileappend "'outputfile2$'" 'locuteur$''tab$''sexe_du_loc$' 'tab$''count_rep' 'tab$''vowel_ID' 'tab$''vowel$' 'tab$''dur_syll' 'tab$'9_mean 'tab$''mean_Fo' 'tab$''mean_f1' 'tab$''mean_f2' 'tab$''mean_f3' 'tab$''mean_f4' 'tab$''mean_f5' 'tab$''bandwidth1' 'tab$''bandwidth2' 'tab$''bandwidth3' 'tab$''bandwidth4' 'tab$''bandwidth5' 'tab$' 'newline$'

if analyser_un_segment_precis = 1
call dessin
endif
#-------subprocedure-------#

endif

endfor
					
fileappend "'outputfile2$'" 'newline$'
endproc

#-----------------------------------
procedure intensite1

for l from 1 to nos
select 'textgrid'
current_syllable = syllable'l'
label$ = Get label of interval... 1 current_syllable

fileappend "'outputfile3$'"  ('label$') 'tab$'

start_syllable = Get starting point... 1 current_syllable
end_syllable = Get end point... 1 current_syllable
		
select 'intensity'							
mean_intensity = Get mean... 'start_syllable' 'end_syllable' 
mean_intensity = round (mean_intensity)	
fileappend "'outputfile3$'" 'mean_intensity' 'newline$' 

endfor
endproc

#-----------------------
procedure intensite2

fileappend "'outputfile3$'" 'newline$''newline$'intensity tier 2'newline$'

for l from 1 to noseq
select 'textgrid'
current_seq = seq'l'
label2$ = Get label of interval... 2 current_seq

start_seq = Get starting point... 2 current_seq
end_seq = Get end point... 2 current_seq
select 'intensity'							
mean_intensity2 = Get mean... 'start_seq' 'end_seq' 
mean_intensity2 = round (mean_intensity2)	
fileappend "'outputfile3$'" ('label2$') 'tab$''mean_intensity2' 'newline$' 
endfor
		
endproc

#--------------------------
procedure intensite3

fileappend "'outputfile3$'" 'newline$''newline$'intensity tier 3'newline$'

for l from 1 to nothird
select 'textgrid'
current_mot = mot'l'
label3$ = Get label of interval... 3 current_mot

start_mot = Get starting point... 3 current_mot		
end_mot = Get end point... 3 current_mot
select 'intensity'							
mean_intensity3 = Get mean... 'start_mot' 'end_mot' 
mean_intensity3 = round (mean_intensity3)	
fileappend "'outputfile3$'" ('label3$') 'tab$' 'mean_intensity3'  'newline$'
endfor
fileappend "'outputfile3$'" 'newline$'


endproc

#-------------------------------
procedure intonation1

select 'sound'
To Pitch... 0.01 75 600
pitch = selected("Pitch")
						
for l from 1 to nos
select 'textgrid'
current_syllable = syllable'l'
label$ = Get label of interval... 1 current_syllable
		
start_syllable = Get starting point... 1 current_syllable
start_syllable = start_syllable + 0.005
end_syllable = Get end point... 1 current_syllable
end_syllable = end_syllable - 0.005
midpt = (start_syllable + end_syllable)/2		

select 'pitch'	
		 						
mean_Fo = Get mean... 'start_syllable' 'end_syllable' Hertz
mean_Fo = round (mean_Fo)	
beg_Fo = Get value at time... start_syllable Hertz Linear
beg_Fo = round (beg_Fo)	
mid_Fo = Get value at time... midpt Hertz Linear
mid_Fo = round (mid_Fo)	
end_Fo = Get value at time... end_syllable Hertz Linear
end_Fo = round (end_Fo)	

fileappend "'outputfile4$'" ('label$') 'tab$' 'mean_Fo' 'tab$''tab$' 'beg_Fo' 'tab$''tab$' 'mid_Fo' 'tab$''tab$' 'end_Fo' 'newline$'
endfor

endproc

#--------------------------------
procedure intonation2

fileappend "'outputfile4$'" 'newline$' 'newline$' Fo Tier 2 'newline$'
fileappend "'outputfile4$'" 'tab$''newline$' mot 'tab$' mean Fo 'tab$' 'tab$' beg Fo 'tab$' 'tab$' mid Fo 'tab$' 'tab$' end Fo 'newline$'
	
for l from 1 to noseq
select 'textgrid'
current_seq = seq'l'
label2$ = Get label of interval... 2 current_seq

start_syllable = Get starting point... 2 current_seq
start_syllable = start_syllable + 0.005
end_syllable = Get end point... 2 current_seq
end_syllable = end_syllable - 0.005
midpt = (start_syllable + end_syllable)/2	

select 'pitch'	
					 						
mean_Fo2 = Get mean... 'start_syllable' 'end_syllable' Hertz
mean_Fo2 = round (mean_Fo2)	
beg_Fo2 = Get value at time... start_syllable Hertz Linear
beg_Fo2 = round (beg_Fo2)	
mid_Fo2 = Get value at time... midpt Hertz Linear
mid_Fo2 = round (mid_Fo2)	
end_Fo2 = Get value at time... end_syllable Hertz Linear
end_Fo2 = round (end_Fo2)	

fileappend "'outputfile4$'" ('label2$') 'tab$' 'mean_Fo2' 'tab$''tab$' 'beg_Fo2' 'tab$''tab$' 'mid_Fo2' 'tab$''tab$' 'end_Fo2' 'newline$'
endfor

endproc

#---------------------------------
procedure intonation3

fileappend "'outputfile4$'" 'newline$' 'newline$' Fo Tier 3 'newline$'

fileappend "'outputfile4$'" 'tab$''newline$' mot 'tab$' mean Fo 'tab$' 'tab$' beg Fo 'tab$' 'tab$' mid Fo 'tab$' 'tab$' end Fo 'newline$'
for l from 1 to nothird
select 'textgrid'
current_mot = mot'l'
label3$ = Get label of interval... 3 current_mot

start_syllable = Get starting point... 3 current_mot
start_syllable = start_syllable + 0.005
end_syllable = Get end point... 3 current_mot
end_syllable = end_syllable - 0.005
midpt = (start_syllable + end_syllable)/2	

select 'pitch'	
		 						
mean_Fo3 = Get mean... 'start_syllable' 'end_syllable' Hertz
mean_Fo3 = round (mean_Fo3)	
beg_Fo3 = Get value at time... start_syllable Hertz Linear
beg_Fo3 = round (beg_Fo3)	
mid_Fo3 = Get value at time... midpt Hertz Linear
mid_Fo3 = round (mid_Fo3)	
end_Fo3 = Get value at time... end_syllable Hertz Linear
end_Fo3 = round (end_Fo3)	

fileappend "'outputfile4$'" ('label3$') 'tab$' 'mean_Fo3' 'tab$''tab$' 'beg_Fo3' 'tab$''tab$' 'mid_Fo3' 'tab$''tab$' 'end_Fo3' 'newline$'
	endfor
fileappend "'outputfile4$'" 'newline$' 'newline$' 


endproc

#-------------------------------------
procedure comptage1bis

noiist = Get number of intervals... 1
nos = 0
for j from 1 to noiist

syllable$ = Get label of interval... 1 j

if syllable$ = analyser_quoi$
nos = nos + 1
syllable'nos' = j
		
elsif analyser_quoi$ = "v++"
	if (syllable$ = "i" or syllable$ = "a" or syllable$ = "E" or syllable$ = "u" or syllable$ = "i:" or syllable$ = "y")
	nos = nos + 1
	syllable'nos' = j
	endif
elsif analyser_quoi$ = "c++"
	if (syllable$ = "c" or syllable$ = "b" or syllable$ = "d" or syllable$ = "f" or syllable$ = "g" or syllable$ = "h"or syllable$ = "j" or syllable$ = "k"
... or syllable$ = "l" or syllable$ = "m" or syllable$ = "n" or syllable$ = "p" or syllable$ = "q"or syllable$ = "r" or syllable$ = "s" or syllable$ = "t"
... or syllable$ = "v" or syllable$ = "x" or syllable$ = "z")
	nos = nos + 1
	syllable'nos' = j
	endif
elsif analyser_quoi$ = "L++"
	if (syllable$ = "l" or syllable$ = "m" or syllable$ = "n" or syllable$ = "r")
	nos = nos + 1
	syllable'nos' = j
	endif

endif
endfor
endproc

#-------------------------------------
procedure dessin

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

Draw circle... mean_f1 mean_f2 27
Text... mean_f1 Centre mean_f2 Half 'label$'
endproc

#-------------------------------------
procedure comptage1ter
noiist = Get number of intervals... 1
nos = 0
for j from 2 to noiist

syllable$ = Get label of interval... 1 j

if syllable$ = analyser_quoi$
call condition1
elsif analyser_quoi$ = "v++"
if (syllable$ = "i" or syllable$ = "a" or syllable$ = "E" or syllable$ = "u" or syllable$ = "i:" or syllable$ = "y")
call condition1
endif
elsif analyser_quoi$ = "c++"
	if (syllable$ = "c" or syllable$ = "b" or syllable$ = "d" or syllable$ = "f" or syllable$ = "g" or syllable$ = "h"or syllable$ = "j" or syllable$ = "k"
... or syllable$ = "l" or syllable$ = "m" or syllable$ = "n" or syllable$ = "p" or syllable$ = "q"or syllable$ = "r" or syllable$ = "s" or syllable$ = "t"
... or syllable$ = "v" or syllable$ = "x" or syllable$ = "z")
call condition1
endif
elsif analyser_quoi$ = "L++"
	if (syllable$ = "l" or syllable$ = "m" or syllable$ = "n" or syllable$ = "r")
call condition1
endif

endif
endfor
endproc

#---------------------------------------
procedure comptage1quar

noiist = Get number of intervals... 1
nos = 0
for j from 1 to (noiist-1)

syllable$ = Get label of interval... 1 j

if syllable$ = analyser_quoi$
call condition2
elsif analyser_quoi$ = "v++"
if (syllable$ = "i" or syllable$ = "a" or syllable$ = "E" or syllable$ = "u" or syllable$ = "i:" or syllable$ = "y")
call condition2
endif
elsif analyser_quoi$ = "c++"
	if (syllable$ = "c" or syllable$ = "b" or syllable$ = "d" or syllable$ = "f" or syllable$ = "g" or syllable$ = "h"or syllable$ = "j" or syllable$ = "k"
... or syllable$ = "l" or syllable$ = "m" or syllable$ = "n" or syllable$ = "p" or syllable$ = "q"or syllable$ = "r" or syllable$ = "s" or syllable$ = "t"
... or syllable$ = "v" or syllable$ = "x" or syllable$ = "z")
call condition2
endif
elsif analyser_quoi$ = "L++"
	if (syllable$ = "l" or syllable$ = "m" or syllable$ = "n" or syllable$ = "r")
call condition2
endif

endif
endfor
endproc

#----------------------------------------
procedure comptage1quint
noiist = Get number of intervals... 1
nos = 0
for j from 2 to (noiist-1)

syllable$ = Get label of interval... 1 j

if syllable$ = analyser_quoi$
call condition3
elsif analyser_quoi$ = "v++"
if (syllable$ = "i" or syllable$ = "a" or syllable$ = "E" or syllable$ = "u" or syllable$ = "i:" or syllable$ = "y")
call condition3
endif
elsif analyser_quoi$ = "c++"
	if (syllable$ = "c" or syllable$ = "b" or syllable$ = "d" or syllable$ = "f" or syllable$ = "g" or syllable$ = "h"or syllable$ = "j" or syllable$ = "k"
... or syllable$ = "l" or syllable$ = "m" or syllable$ = "n" or syllable$ = "p" or syllable$ = "q"or syllable$ = "r" or syllable$ = "s" or syllable$ = "t"
... or syllable$ = "v" or syllable$ = "x" or syllable$ = "z")
call condition3	
endif
elsif analyser_quoi$ = "L++"
	if (syllable$ = "l" or syllable$ = "m" or syllable$ = "n" or syllable$ = "r")
call condition3
endif
	


endif
endfor
endproc

#------------------------------
procedure condition1
syllable_x$ = Get label of interval... 1 j -1

if syllable_x$ =contexte_avant$
nos = nos + 1
syllable'nos' = j
		
		
elsif contexte_avant$ = "v++"
	if (syllable_x$ = "i" or syllable_x$ = "a" or syllable_x$ = "E" or syllable_x$ = "u" or syllable_x$ = "i:" or syllable_x$ = "y")	
	nos = nos + 1
	syllable'nos' = j
	endif
		
elsif contexte_avant$ = "c++"
	if (syllable_x$ = "c" or syllable_x$ = "b" or syllable_x$ = "d" or syllable_x$ = "f" or syllable_x$ = "g" or syllable_x$ = "h"or syllable_x$ = "j" or syllable_x$ = "k"
... or syllable_x$ = "l" or syllable_x$ = "m" or syllable_x$ = "n" or syllable_x$ = "p" or syllable_x$ = "q"or syllable_x$ = "r" or syllable_x$ = "s" or syllable_x$ = "t"
... or syllable_x$ = "v" or syllable_x$ = "x" or syllable_x$ = "z")
	nos = nos + 1
	syllable'nos' = j
	endif
		
elsif contexte_avant$ = "L++"
	if (syllable_x$ = "l" or syllable_x$ = "m" or syllable_x$ = "n" or syllable_x$ = "r")
	nos = nos + 1
	syllable'nos' = j
	endif
endif
endproc

#-------------------
procedure condition2
syllable_xx$ = Get label of interval... 1 j +1

if syllable_xx$ =contexte_apres$
nos = nos + 1
syllable'nos' = j
elsif contexte_apres$ = "v++"
	if (syllable_xx$ = "i" or syllable_xx$ = "a" or syllable_xx$ = "E" or syllable_xx$ = "u" or syllable_xx$ = "i:" or syllable_xx$ = "y")
nos = nos + 1
syllable'nos' = j
endif


elsif contexte_apres$ = "c++"
	if (syllable_xx$ = "c" or syllable_xx$ = "b" or syllable_xx$ = "d" or syllable_xx$ = "f" or syllable_xx$ = "g" or syllable_xx$ = "h"or syllable_xx$ = "j" 
... or syllable_xx$ = "l" or syllable_xx$ = "m" or syllable_xx$ = "n" or syllable_xx$ = "p" or syllable_xx$ = "q"or syllable_xx$ = "r" or syllable_xx$ = "s" or syllable_xx$ = "t"
... or syllable_xx$ = "v" or syllable_xx$ = "x" or syllable_xx$ = "z" or syllable_xx$ = "k")
nos = nos + 1
syllable'nos' = j
endif


elsif contexte_apres$ = "L++"
	if (syllable_xx$ = "l" or syllable_xx$ = "m" or syllable_xx$ = "n" or syllable_xx$ = "r")
nos = nos + 1
syllable'nos' = j
endif

endif
endproc


#-------------------
procedure condition3
syllable_x$ = Get label of interval... 1 j -1
syllable_xx$ = Get label of interval... 1 j +1

if (syllable_xx$ =contexte_apres$ and syllable_x$ =contexte_avant$)
	nos = nos + 1
	syllable'nos' = j


elsif (contexte_avant$ = "c++" and contexte_apres$ = "c++")
if (syllable_x$ = "c" or syllable_x$ = "b" or syllable_x$ = "d" or syllable_x$ = "f" or syllable_x$ = "g" or syllable_x$ = "h"or syllable_x$ = "j" or syllable_x$ = "k"
... or syllable_x$ = "l" or syllable_x$ = "m" or syllable_x$ = "n" or syllable_x$ = "p" or syllable_x$ = "q"or syllable_x$ = "r" or syllable_x$ = "s" or syllable_x$ = "t"
... or syllable_x$ = "v" or syllable_x$ = "x" or syllable_x$ = "z")

if (syllable_xx$ = "c" or syllable_xx$ = "b" or syllable_xx$ = "d" or syllable_xx$ = "f" or syllable_xx$ = "g" or syllable_xx$ = "h"or syllable_xx$ = "j" or syllable_xx$ = "k"
... or syllable_xx$ = "l" or syllable_xx$ = "m" or syllable_xx$ = "n" or syllable_xx$ = "p" or syllable_xx$ = "q"or syllable_xx$ = "r" or syllable_xx$ = "s" or syllable_xx$ = "t"
... or syllable_xx$ = "v" or syllable_xx$ = "x" or syllable_xx$ = "z")

nos = nos + 1
syllable'nos' = j
endif
endif


elsif (contexte_apres$= "c++" and syllable_x$ =contexte_avant$)

if (syllable_xx$ = "c" or syllable_xx$ = "b" or syllable_xx$ = "d" or syllable_xx$ = "f" or syllable_xx$ = "g" or syllable_xx$ = "h"or syllable_xx$ = "j" or syllable_xx$ = "k"
... or syllable_xx$ = "l" or syllable_xx$ = "m" or syllable_xx$ = "n" or syllable_xx$ = "p" or syllable_xx$ = "q"or syllable_xx$ = "r" or syllable_xx$ = "s" or syllable_xx$ = "t"
... or syllable_xx$ = "v" or syllable_xx$ = "x" or syllable_xx$ = "z")
nos = nos + 1
syllable'nos' = j
endif




elsif (contexte_avant$ = "c++" and syllable_xx$ =contexte_apres$)
if (syllable_x$ = "c" or syllable_x$ = "b" or syllable_x$ = "d" or syllable_x$ = "f" or syllable_x$ = "g" or syllable_x$ = "h"or syllable_x$ = "j" or syllable_x$ = "k"
... or syllable_x$ = "l" or syllable_x$ = "m" or syllable_x$ = "n" or syllable_x$ = "p" or syllable_x$ = "q"or syllable_x$ = "r" or syllable_x$ = "s" or syllable_x$ = "t"
... or syllable_x$ = "v" or syllable_x$ = "x" or syllable_x$ = "z")
nos = nos + 1
syllable'nos' = j
endif

endif
endproc

#-------------------

select 'formant'
Remove
select 'formant_close'
Remove
select 'intensity'
Remove
select 'pitch'
Remove

select 'sound'
plus 'textgrid'

printline Vos résultats ont été enregistrés sous 'path$':