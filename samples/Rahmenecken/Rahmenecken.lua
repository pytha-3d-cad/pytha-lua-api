-- Pytha V25 Plugin zur Erzeugung von Schlitz- und Rahmeneckverbindungen in verschiedenen Ausfuehrungen
-- (C) Peter Laube, 09-2021, Version 1.1
-- Vorgehen: Erzeugung des Zapfenstuecks mit allen gewuenschten Parametern. Ableitung des Schlitzstuecks ueber boolsche Differenz

function main()
local data = {	breite = 60,
				dicke = 24,
				ueberstand = 50,
				auswahl = 1,
				tiefe = 8,
				hoehe = 8,
				staerke = 3,
				ruecksprung = 3,
				fase = false
				}
	recreate_geometry(data)
	pyui.run_modal_dialog(Rahmen_dialog, data)
end 

-- Abfragen im Dialog definieren

function Rahmen_dialog(dialog, data)
	local controls = {}
	dialog:set_window_title("Rahmenecken by Peter Laube")
	
	local label1 = dialog:create_label(1, pyloc "Breite")
	local breite = dialog:create_text_box(2, pyui.format_length(data.breite))
	local label2 = dialog:create_label(3, pyloc "Dicke")
	local dicke = dialog:create_text_box(4, pyui.format_length(data.dicke))
	local label3 = dialog:create_label(1, pyloc"Ausfuehrung")
	local auswahl = dialog:create_drop_list(2)
	auswahl:insert_control_item(pyloc "ohne")
	auswahl:insert_control_item(pyloc "Falz")
	auswahl:insert_control_item(pyloc "Nut")
	auswahl:set_control_selection(data.auswahl)
	local label4 = dialog:create_label(3, pyloc "Falz-/Nutbreite")
	local tiefe = dialog:create_text_box(4, pyui.format_length(data.tiefe))
	local label5 = dialog:create_label(3, pyloc "Falz-/Nuttiefe")
	local hoehe = dialog:create_text_box(4, pyui.format_length(data.hoehe))
	dialog:create_align({1,4})
	controls.check_fase = dialog:create_check_box({1,2}, pyloc "Fase")
	controls.check_fase:set_control_checked(data.fase)
	local label7 = dialog:create_label(3, pyloc "Fasenbreite")
	local ruecksprung = dialog:create_text_box(4, pyui.format_length(data.ruecksprung))
	local label6 = dialog:create_label(3, pyloc "Fasentiefe")
	local staerke = dialog:create_text_box(4, pyui.format_length(data.staerke))
	local ok = dialog:create_ok_button(3)
    local cancel = dialog:create_cancel_button(4)
	
	if data.auswahl == 1 then
		label4:disable_control()
		label5:disable_control()
		tiefe:disable_control()
		hoehe:disable_control()
	else
		label4:enable_control()
		label5:enable_control()
		tiefe:enable_control()
		hoehe:enable_control()
	end	
	
	if data.fase == false then
		label6:disable_control()
		label7:disable_control()
		staerke:disable_control()
		ruecksprung:disable_control()
	else
		label6:enable_control()
		label7:enable_control()
		staerke:enable_control()
		ruecksprung:enable_control()
	end	
	
-- Refresh bei Eingaben setzen
	
	breite:set_on_change_handler(function(text)
        data.breite = pyui.parse_length(text) or data.breite
		if data.breite == nil then
			data.breite = 0
		end
		if data.breite > 0 then
		recreate_geometry(data)
	end
    end)
	
    dicke:set_on_change_handler(function(text)
        data.dicke = pyui.parse_length(text) or data.dicke
		if data.dicke == nil then
			data.dicke = 0
		end
		if data.dicke > 0 then
		recreate_geometry(data)
	end
    end)

	auswahl:set_on_change_handler(function(text, new_index)
		data.auswahl = new_index
		if data.auswahl == 1 then
			label4:disable_control()
			label5:disable_control()
			tiefe:disable_control()
			hoehe:disable_control()
		else
			label4:enable_control()
			label5:enable_control()
			tiefe:enable_control()
			hoehe:enable_control()
		end	
		recreate_geometry(data)
	end)
	
	tiefe:set_on_change_handler(function(text)
        data.tiefe = pyui.parse_length(text) or data.tiefe
		if data.tiefe == nil then
			data.tiefe = 0
		end
		if data.tiefe > 0 then
		recreate_geometry(data)
	end
	end)
	
	hoehe:set_on_change_handler(function(text)
        data.hoehe = pyui.parse_length(text) or data.hoehe
		if data.hoehe == nil then
			data.hoehe = 0
		end
		if data.hoehe > 0 then
		recreate_geometry(data)
	end
	end)
	
	controls.check_fase:set_on_click_handler(function(state)
		data.fase = state
		if data.fase == false then
		label6:disable_control()
		label7:disable_control()
		staerke:disable_control()
		ruecksprung:disable_control()
	else
		label6:enable_control()
		label7:enable_control()
		staerke:enable_control()
		ruecksprung:enable_control()
	end	
		recreate_geometry(data)
		
	end)
	
	staerke:set_on_change_handler(function(text)
        data.staerke = pyui.parse_length(text) or data.staerke
		if data.staerke == nil then
			data.staerke = 0
		end
		if data.staerke > 0 then
		recreate_geometry(data)
	end
    end)
	
	ruecksprung:set_on_change_handler(function(text)
        data.ruecksprung = pyui.parse_length(text) or data.ruecksprung
		if data.ruecksprung == nil then
			data.ruecksprung = 0
		end
		if data.ruecksprung > 0 then
		recreate_geometry(data)
	end
    end)
	
end

-- Erzeugen der Geometrie

function recreate_geometry(data)

-- Refresh bei neuer Dateneingabe - alte Objekte loeschen
	if data.current_element_ZS ~= nil then
	pytha.delete_element(data.current_element_ZS)
	end
	if data.current_element_SS ~=nil then
	pytha.delete_element(data.current_element_SS)
	end

	recreate_geometry_Zapfenstueck(data)
	recreate_geometry_Schlitzstueck(data)

end

function recreate_geometry_Zapfenstueck(data)
	local current_element_ZS1 = nil
	local current_element_ZS2 = nil
	local current_element_nichtfalz = nil
	local current_element_nichtnut = nil
	local current_element_nichtfase = nil
	-- Zapfenstueck Querschnitt
	current_element_ZS1 = pytha.create_block(data.breite,data.dicke/3,data.breite, {0,data.dicke/3,data.ueberstand})
	current_element_ZS2 = pytha.create_block(data.ueberstand,data.dicke,data.breite, {data.breite,0,data.ueberstand})
	-- Rueckriss Falz erzeugen
	if data.auswahl == 2 then
		current_element_nichtfalz = pytha.create_block(-data.hoehe,-data.tiefe,data.breite, {data.breite,data.dicke,data.ueberstand})
	end
	-- Idioteneck für falsche Nutverbindung erzeugen
	if data.auswahl == 3 then
		current_element_nichtnut = pytha.create_block(-data.hoehe,data.tiefe,data.breite, {data.breite,(data.dicke-data.tiefe)/2,data.ueberstand})
	end
	-- Rueckriss Fase erzeugen
	if data.fase == true then
		current_element_nichtfasenflaeche=pytha.create_polygon({{data.breite-data.ruecksprung,0,data.ueberstand},{data.breite,0,data.ueberstand},{data.breite,data.staerke,data.ueberstand}}) 
		current_element_nichtfase=pytha.create_profile(current_element_nichtfasenflaeche, data.breite)[1]
		pytha.delete_element(current_element_nichtfasenflaeche)
	end
	-- Zapfenstueck Summe bilden
	data.current_element_ZS = pytha.boole_part_union({current_element_ZS1, current_element_ZS2, current_element_nichtfalz, current_element_nichtnut, current_element_nichtfase})
	-- Name vergeben
	pytha.set_element_name(data.current_element_ZS, "Zapfenstück")
	-- Aktion "Bewegen" fuer den Zusammenbau hinzufuegen
	local distanz = 2*data.breite
	local bewege_string = "mov("..distanz..",0,0)"
	pytha.set_element_attributes(data.current_element_ZS, {action_string = bewege_string})
	-- Falz abziehen
	if data.auswahl == 2 then
		data.current_element_falz = pytha.create_block(data.breite+data.ueberstand, -data.tiefe,data.hoehe, {0,data.dicke,data.ueberstand})
		pytha.boole_part_difference(data.current_element_ZS, data.current_element_falz)
	end
	-- Nut abziehen
	if data.auswahl == 3 then
		data.current_element_nut = pytha.create_block(data.breite+data.ueberstand, data.tiefe,data.hoehe, {0,(data.dicke-data.tiefe)/2,data.ueberstand})
		pytha.boole_part_difference(data.current_element_ZS, data.current_element_nut)
	end
	-- Fase abziehen
	if data.fase == true then
		data.current_element_fasenflaeche=pytha.create_polygon({{0,data.staerke,0},{0,0,0},{0,0,data.ruecksprung}}, {0,0,data.ueberstand})
		data.current_element_fase=pytha.create_profile(data.current_element_fasenflaeche, -(data.breite+data.ueberstand))
		pytha.delete_element(data.current_element_fasenflaeche)
		pytha.boole_part_difference(data.current_element_ZS, data.current_element_fase)
	end
end


function recreate_geometry_Schlitzstueck(data)
	
	-- Schlitzstueck Querschnitt
	data.current_element_SS = pytha.create_block(data.breite,data.dicke,data.ueberstand+data.breite, {0,0,0})
	-- Name vergeben
	pytha.set_element_name(data.current_element_SS, "Schlitzstück")
	-- Falz abziehen
	if data.auswahl == 2 then
		data.current_element_falz = pytha.create_block(-data.hoehe,-data.tiefe,data.breite+data.ueberstand, {data.breite,data.dicke,0})
		pytha.boole_part_difference(data.current_element_SS, data.current_element_falz)
	end
	-- Nut abziehen
	if data.auswahl == 3 then
		data.current_element_nut = pytha.create_block(-data.hoehe,data.tiefe,data.breite+data.ueberstand, {data.breite,(data.dicke-data.tiefe)/2,0})
		pytha.boole_part_difference(data.current_element_SS, data.current_element_nut)
	end
		-- Fase abziehen
	if data.fase == true then
		data.current_element_fasenflaeche=pytha.create_polygon({{data.breite-data.ruecksprung,0,0},{data.breite,0,0},{data.breite,data.staerke,0}}) 
		data.current_element_fase=pytha.create_profile(data.current_element_fasenflaeche, data.breite+data.ueberstand)
		pytha.delete_element(data.current_element_fasenflaeche)
		pytha.boole_part_difference(data.current_element_SS, data.current_element_fase)
	end
	
	-- Schlitzstueck mit Zapfenstueck boolschen
	-- Klon Zapfenstueck zum Boolschen erzeugen
	data.current_element_ZSklon = pytha.copy_element (data.current_element_ZS, {0,0,0})[1]
	pytha.boole_part_difference(data.current_element_SS, data.current_element_ZSklon)
end
