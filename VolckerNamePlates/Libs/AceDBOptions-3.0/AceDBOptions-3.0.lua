--- AceDBOptions-3.0 provides a universal AceConfig options screen for managing AceDB-3.0 profiles.
-- @class file
-- @name AceDBOptions-3.0
-- @release $Id: AceDBOptions-3.0.lua 938 2010-06-13 07:21:38Z nevcairiel $
local ACEDBO_MAJOR, ACEDBO_MINOR = "AceDBOptions-3.0", 12
local AceDBOptions, oldminor = LibStub:NewLibrary(ACEDBO_MAJOR, ACEDBO_MINOR)

if not AceDBOptions then return end -- No upgrade needed

-- Lua APIs
local pairs, next = pairs, next

-- WoW APIs
local UnitClass = UnitClass

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: NORMAL_FONT_COLOR_CODE, FONT_COLOR_CODE_CLOSE

AceDBOptions.optionTables = AceDBOptions.optionTables or {}
AceDBOptions.handlers = AceDBOptions.handlers or {}

--[[
	Localization of AceDBOptions-3.0
]]

local L = {
	default = "Default",
	intro = "You can change the active database profile, so you can have different settings for every character.",
	reset_desc = "Reset the current profile back to its default values, in case your configuration is broken, or you simply want to start over.",
	reset = "Reset Profile",
	reset_sub = "Reset the current profile to the default",
	choose_desc = "You can either create a new profile by entering a name in the editbox, or choose one of the already existing profiles.",
	new = "New",
	new_sub = "Create a new empty profile.",
	choose = "Existing Profiles",
	choose_sub = "Select one of your currently available profiles.",
	copy_desc = "Copy the settings from one existing profile into the currently active profile.",
	copy = "Copy From",
	delete_desc = "Delete existing and unused profiles from the database to save space, and cleanup the SavedVariables file.",
	delete = "Delete a Profile",
	delete_sub = "Deletes a profile from the database.",
	delete_confirm = "Are you sure you want to delete the selected profile?",
	profiles = "Profiles",
	profiles_sub = "Manage Profiles",
	current = "Current Profile:",
}

local LOCALE = GetLocale()
if LOCALE == "deDE" then
	L["default"] = "Standard"
	L["intro"] = "Hier kannst du das aktive Datenbankprofile \195\164ndern, damit du verschiedene Einstellungen f\195\188r jeden Charakter erstellen kannst, wodurch eine sehr flexible Konfiguration m\195\182glich wird." 
	L["reset_desc"] = "Setzt das momentane Profil auf Standardwerte zur\195\188ck, f\195\188r den Fall das mit der Konfiguration etwas schief lief oder weil du einfach neu starten willst."
	L["reset"] = "Profil zur\195\188cksetzen"
	L["reset_sub"] = "Das aktuelle Profil auf Standard zur\195\188cksetzen."
	L["choose_desc"] = "Du kannst ein neues Profil erstellen, indem du einen neuen Namen in der Eingabebox 'Neu' eingibst, oder w\195\164hle eines der vorhandenen Profile aus."
	L["new"] = "Neu"
	L["new_sub"] = "Ein neues Profil erstellen."
	L["choose"] = "Vorhandene Profile"
	L["choose_sub"] = "W\195\164hlt ein bereits vorhandenes Profil aus."
	L["copy_desc"] = "Kopiere die Einstellungen von einem vorhandenen Profil in das aktive Profil."
	L["copy"] = "Kopieren von..."
	L["delete_desc"] = "L\195\182sche vorhandene oder unbenutzte Profile aus der Datenbank um Platz zu sparen und um die SavedVariables Datei 'sauber' zu halten."
	L["delete"] = "Profil l\195\182schen"
	L["delete_sub"] = "L\195\182scht ein Profil aus der Datenbank."
	L["delete_confirm"] = "Willst du das ausgew\195\164hlte Profil wirklich l\195\182schen?"
	L["profiles"] = "Profile"
	L["profiles_sub"] = "Profile verwalten"
	--L["current"] = "Current Profile:"
elseif LOCALE == "frFR" then
	L["default"] = "D\195\169faut"
	L["intro"] = "Vous pouvez changer le profil actuel afin d'avoir des param\195\168tres diff\195\169rents pour chaque personnage, permettant ainsi d'avoir une configuration tr\195\168s flexible."
	L["reset_desc"] = "R\195\169initialise le profil actuel au cas o\195\185 votre configuration est corrompue ou si vous voulez tout simplement faire table rase."
	L["reset"] = "R\195\169initialiser le profil"
	L["reset_sub"] = "R\195\169initialise le profil actuel avec les param\195\168tres par d\195\169faut."
	L["choose_desc"] = "Vous pouvez cr\195\169er un nouveau profil en entrant un nouveau nom dans la bo\195\174te de saisie, ou en choississant un des profils d\195\169j\195\160 existants."
	L["new"] = "Nouveau"
	L["new_sub"] = "Cr\195\169\195\169e un nouveau profil vierge."
	L["choose"] = "Profils existants"
	L["choose_sub"] = "Permet de choisir un des profils d\195\169j\195\160 disponibles."
	L["copy_desc"] = "Copie les param\195\168tres d'un profil d\195\169j\195\160 existant dans le profil actuellement actif."
	L["copy"] = "Copier \195\160 partir de"
	L["delete_desc"] = "Supprime les profils existants inutilis\195\169s de la base de donn\195\169es afin de gagner de la place et de nettoyer le fichier SavedVariables."
	L["delete"] = "Supprimer un profil"
	L["delete_sub"] = "Supprime un profil de la base de donn\195\169es."
	L["delete_confirm"] = "Etes-vous s\195\187r de vouloir supprimer le profil s\195\169lectionn\195\169 ?"
	L["profiles"] = "Profils"
	L["profiles_sub"] = "Gestion des profils"
	--L["current"] = "Current Profile:"
elseif LOCALE == "koKR" then
	L["default"] = "ê¸°ë³¸ê°’"
	L["intro"] = "ëª¨ë“  ìºë¦­í„°ì˜ ë‹¤ì–‘í•œ ì„¤ì •ê³¼ ì‚¬ìš©ì¤‘ì¸ ë°ì´í„°ë² ì´ìŠ¤ í”„ë¡œí•„, ì–´ëŠê²ƒì´ë˜ì§€ ë§¤ìš° ë‹¤ë£¨ê¸° ì‰½ê²Œ ë°”ê¿€ìˆ˜ ìžˆìŠµë‹ˆë‹¤." 
	L["reset_desc"] = "ë‹¨ìˆœížˆ ë‹¤ì‹œ ìƒˆë¡­ê²Œ êµ¬ì„±ì„ ì›í•˜ëŠ” ê²½ìš°, í˜„ìž¬ í”„ë¡œí•„ì„ ê¸°ë³¸ê°’ìœ¼ë¡œ ì´ˆê¸°í™” í•©ë‹ˆë‹¤."
	L["reset"] = "í”„ë¡œí•„ ì´ˆê¸°í™”"
	L["reset_sub"] = "í˜„ìž¬ì˜ í”„ë¡œí•„ì„ ê¸°ë³¸ê°’ìœ¼ë¡œ ì´ˆê¸°í™” í•©ë‹ˆë‹¤"
	L["choose_desc"] = "ìƒˆë¡œìš´ ì´ë¦„ì„ ìž…ë ¥í•˜ê±°ë‚˜, ì´ë¯¸ ìžˆëŠ” í”„ë¡œí•„ì¤‘ í•˜ë‚˜ë¥¼ ì„ íƒí•˜ì—¬ ìƒˆë¡œìš´ í”„ë¡œí•„ì„ ë§Œë“¤ ìˆ˜ ìžˆìŠµë‹ˆë‹¤."
	L["new"] = "ìƒˆë¡œìš´ í”„ë¡œí•„"
	L["new_sub"] = "ìƒˆë¡œìš´ í”„ë¡œí•„ì„ ë§Œë“­ë‹ˆë‹¤."
	L["choose"] = "í”„ë¡œí•„ ì„ íƒ"
	L["choose_sub"] = "ë‹¹ì‹ ì´ í˜„ìž¬ ì´ìš©í• ìˆ˜ ìžˆëŠ” í”„ë¡œí•„ì„ ì„ íƒí•©ë‹ˆë‹¤."
	L["copy_desc"] = "í˜„ìž¬ ì‚¬ìš©ì¤‘ì¸ í”„ë¡œí•„ì—, ì„ íƒí•œ í”„ë¡œí•„ì˜ ì„¤ì •ì„ ë³µì‚¬í•©ë‹ˆë‹¤."
	L["copy"] = "ë³µì‚¬"
	L["delete_desc"] = "ë°ì´í„°ë² ì´ìŠ¤ì— ì‚¬ìš©ì¤‘ì´ê±°ë‚˜ ì €ìž¥ëœ í”„ë¡œíŒŒì¼ ì‚­ì œë¡œ SavedVariables íŒŒì¼ì˜ ì •ë¦¬ì™€ ê³µê°„ ì ˆì•½ì´ ë©ë‹ˆë‹¤."
	L["delete"] = "í”„ë¡œí•„ ì‚­ì œ"
	L["delete_sub"] = "ë°ì´í„°ë² ì´ìŠ¤ì˜ í”„ë¡œí•„ì„ ì‚­ì œí•©ë‹ˆë‹¤."
	L["delete_confirm"] = "ì •ë§ë¡œ ì„ íƒí•œ í”„ë¡œí•„ì˜ ì‚­ì œë¥¼ ì›í•˜ì‹­ë‹ˆê¹Œ?"
	L["profiles"] = "í”„ë¡œí•„"
	L["profiles_sub"] = "í”„ë¡œí•„ ì„¤ì •"
	--L["current"] = "Current Profile:"
elseif LOCALE == "esES" or LOCALE == "esMX" then
	L["default"] = "Por defecto"
	L["intro"] = "Puedes cambiar el perfil activo de tal manera que cada personaje tenga diferentes configuraciones."
	L["reset_desc"] = "Reinicia el perfil actual a los valores por defectos, en caso de que se haya estropeado la configuraciÃ³n o quieras volver a empezar de nuevo."
	L["reset"] = "Reiniciar Perfil"
	L["reset_sub"] = "Reinicar el perfil actual al de por defecto"
	L["choose_desc"] = "Puedes crear un nuevo perfil introduciendo un nombre en el recuadro o puedes seleccionar un perfil de los ya existentes."
	L["new"] = "Nuevo"
	L["new_sub"] = "Crear un nuevo perfil vacio."
	L["choose"] = "Perfiles existentes"
	L["choose_sub"] = "Selecciona uno de los perfiles disponibles."
	L["copy_desc"] = "Copia los ajustes de un perfil existente al perfil actual."
	L["copy"] = "Copiar de"
	L["delete_desc"] = "Borra los perfiles existentes y sin uso de la base de datos para ganar espacio y limpiar el archivo SavedVariables."
	L["delete"] = "Borrar un Perfil"
	L["delete_sub"] = "Borra un perfil de la base de datos."
	L["delete_confirm"] = "Â¿Estas seguro que quieres borrar el perfil seleccionado?"
	L["profiles"] = "Perfiles"
	L["profiles_sub"] = "Manejar Perfiles"
	--L["current"] = "Current Profile:"
elseif LOCALE == "zhTW" then
	L["default"] = "é è¨­"
	L["intro"] = "ä½ å¯ä»¥é¸æ“‡ä¸€å€‹æ´»å‹•çš„è³‡æ–™è¨­å®šæª”ï¼Œé€™æ¨£ä½ çš„æ¯å€‹è§’è‰²å°±å¯ä»¥æ“æœ‰ä¸åŒçš„è¨­å®šå€¼ï¼Œå¯ä»¥çµ¦ä½ çš„æ’ä»¶è¨­å®šå¸¶ä¾†æ¥µå¤§çš„éˆæ´»æ€§ã€‚" 
	L["reset_desc"] = "å°‡ç•¶å‰çš„è¨­å®šæª”æ¢å¾©åˆ°å®ƒçš„é è¨­å€¼ï¼Œç”¨æ–¼ä½ çš„è¨­å®šæª”æå£žï¼Œæˆ–è€…ä½ åªæ˜¯æƒ³é‡ä¾†çš„æƒ…æ³ã€‚"
	L["reset"] = "é‡ç½®è¨­å®šæª”"
	L["reset_sub"] = "å°‡ç•¶å‰çš„è¨­å®šæª”æ¢å¾©ç‚ºé è¨­å€¼"
	L["choose_desc"] = "ä½ å¯ä»¥é€šéŽåœ¨æ–‡æœ¬æ¡†å…§è¼¸å…¥ä¸€å€‹åå­—å‰µç«‹ä¸€å€‹æ–°çš„è¨­å®šæª”ï¼Œä¹Ÿå¯ä»¥é¸æ“‡ä¸€å€‹å·²ç¶“å­˜åœ¨çš„è¨­å®šæª”ã€‚"
	L["new"] = "æ–°å»º"
	L["new_sub"] = "æ–°å»ºä¸€å€‹ç©ºçš„è¨­å®šæª”ã€‚"
	L["choose"] = "ç¾æœ‰çš„è¨­å®šæª”"
	L["choose_sub"] = "å¾žç•¶å‰å¯ç”¨çš„è¨­å®šæª”è£é¢é¸æ“‡ä¸€å€‹ã€‚"
	L["copy_desc"] = "å¾žç•¶å‰æŸå€‹å·²ä¿å­˜çš„è¨­å®šæª”è¤‡è£½åˆ°ç•¶å‰æ­£ä½¿ç”¨çš„è¨­å®šæª”ã€‚"
	L["copy"] = "è¤‡è£½è‡ª"
	L["delete_desc"] = "å¾žè³‡æ–™åº«è£åˆªé™¤ä¸å†ä½¿ç”¨çš„è¨­å®šæª”ï¼Œä»¥ç¯€çœç©ºé–“ï¼Œä¸¦ä¸”æ¸…ç†SavedVariablesæª”ã€‚"
	L["delete"] = "åˆªé™¤ä¸€å€‹è¨­å®šæª”"
	L["delete_sub"] = "å¾žè³‡æ–™åº«è£åˆªé™¤ä¸€å€‹è¨­å®šæª”ã€‚"
	L["delete_confirm"] = "ä½ ç¢ºå®šè¦åˆªé™¤æ‰€é¸æ“‡çš„è¨­å®šæª”å—Žï¼Ÿ"
	L["profiles"] = "è¨­å®šæª”"
	L["profiles_sub"] = "ç®¡ç†è¨­å®šæª”"
	--L["current"] = "Current Profile:"
elseif LOCALE == "zhCN" then
	L["default"] = "é»˜è®¤"
	L["intro"] = "ä½ å¯ä»¥é€‰æ‹©ä¸€ä¸ªæ´»åŠ¨çš„æ•°æ®é…ç½®æ–‡ä»¶ï¼Œè¿™æ ·ä½ çš„æ¯ä¸ªè§’è‰²å°±å¯ä»¥æ‹¥æœ‰ä¸åŒçš„è®¾ç½®å€¼ï¼Œå¯ä»¥ç»™ä½ çš„æ’ä»¶é…ç½®å¸¦æ¥æžå¤§çš„çµæ´»æ€§ã€‚" 
	L["reset_desc"] = "å°†å½“å‰çš„é…ç½®æ–‡ä»¶æ¢å¤åˆ°å®ƒçš„é»˜è®¤å€¼ï¼Œç”¨äºŽä½ çš„é…ç½®æ–‡ä»¶æŸåï¼Œæˆ–è€…ä½ åªæ˜¯æƒ³é‡æ¥çš„æƒ…å†µã€‚"
	L["reset"] = "é‡ç½®é…ç½®æ–‡ä»¶"
	L["reset_sub"] = "å°†å½“å‰çš„é…ç½®æ–‡ä»¶æ¢å¤ä¸ºé»˜è®¤å€¼"
	L["choose_desc"] = "ä½ å¯ä»¥é€šè¿‡åœ¨æ–‡æœ¬æ¡†å†…è¾“å…¥ä¸€ä¸ªåå­—åˆ›ç«‹ä¸€ä¸ªæ–°çš„é…ç½®æ–‡ä»¶ï¼Œä¹Ÿå¯ä»¥é€‰æ‹©ä¸€ä¸ªå·²ç»å­˜åœ¨çš„é…ç½®æ–‡ä»¶ã€‚"
	L["new"] = "æ–°å»º"
	L["new_sub"] = "æ–°å»ºä¸€ä¸ªç©ºçš„é…ç½®æ–‡ä»¶ã€‚"
	L["choose"] = "çŽ°æœ‰çš„é…ç½®æ–‡ä»¶"
	L["choose_sub"] = "ä»Žå½“å‰å¯ç”¨çš„é…ç½®æ–‡ä»¶é‡Œé¢é€‰æ‹©ä¸€ä¸ªã€‚"
	L["copy_desc"] = "ä»Žå½“å‰æŸä¸ªå·²ä¿å­˜çš„é…ç½®æ–‡ä»¶å¤åˆ¶åˆ°å½“å‰æ­£ä½¿ç”¨çš„é…ç½®æ–‡ä»¶ã€‚"
	L["copy"] = "å¤åˆ¶è‡ª"
	L["delete_desc"] = "ä»Žæ•°æ®åº“é‡Œåˆ é™¤ä¸å†ä½¿ç”¨çš„é…ç½®æ–‡ä»¶ï¼Œä»¥èŠ‚çœç©ºé—´ï¼Œå¹¶ä¸”æ¸…ç†SavedVariablesæ–‡ä»¶ã€‚"
	L["delete"] = "åˆ é™¤ä¸€ä¸ªé…ç½®æ–‡ä»¶"
	L["delete_sub"] = "ä»Žæ•°æ®åº“é‡Œåˆ é™¤ä¸€ä¸ªé…ç½®æ–‡ä»¶ã€‚"
	L["delete_confirm"] = "ä½ ç¡®å®šè¦åˆ é™¤æ‰€é€‰æ‹©çš„é…ç½®æ–‡ä»¶ä¹ˆï¼Ÿ"
	L["profiles"] = "é…ç½®æ–‡ä»¶"
	L["profiles_sub"] = "ç®¡ç†é…ç½®æ–‡ä»¶"
	--L["current"] = "Current Profile:"
elseif LOCALE == "ruRU" then
	L["default"] = "ÐŸÐ¾ ÑƒÐ¼Ð¾Ð»Ñ‡Ð°Ð½Ð¸ÑŽ"
	L["intro"] = "Ð˜Ð·Ð¼ÐµÐ½ÑÑ Ð°ÐºÑ‚Ð¸Ð²Ð½Ñ‹Ð¹ Ð¿Ñ€Ð¾Ñ„Ð¸Ð»ÑŒ, Ð²Ñ‹ Ð¼Ð¾Ð¶ÐµÑ‚Ðµ Ð·Ð°Ð´Ð°Ñ‚ÑŒ Ñ€Ð°Ð·Ð»Ð¸Ñ‡Ð½Ñ‹Ðµ Ð½Ð°ÑÑ‚Ñ€Ð¾Ð¹ÐºÐ¸ Ð¼Ð¾Ð´Ð¸Ñ„Ð¸ÐºÐ°Ñ†Ð¸Ð¹ Ð´Ð»Ñ ÐºÐ°Ð¶Ð´Ð¾Ð³Ð¾ Ð¿ÐµÑ€ÑÐ¾Ð½Ð°Ð¶Ð°."
	L["reset_desc"] = "Ð•ÑÐ»Ð¸ Ð²Ð°ÑˆÐ° ÐºÐ¾Ð½Ñ„Ð¸Ð³ÑƒÑ€Ð°Ñ†Ð¸Ð¸ Ð¸ÑÐ¿Ð¾Ñ€Ñ‡ÐµÐ½Ð° Ð¸Ð»Ð¸ ÐµÑÐ»Ð¸ Ð²Ñ‹ Ñ…Ð¾Ñ‚Ð¸Ñ‚Ðµ Ð½Ð°ÑÑ‚Ñ€Ð¾Ð¸Ñ‚ÑŒ Ð²ÑÑ‘ Ð·Ð°Ð½Ð¾Ð²Ð¾ - ÑÐ±Ñ€Ð¾ÑÑŒÑ‚Ðµ Ñ‚ÐµÐºÑƒÑ‰Ð¸Ð¹ Ð¿Ñ€Ð¾Ñ„Ð¸Ð»ÑŒ Ð½Ð° ÑÑ‚Ð°Ð½Ð´Ð°Ñ€Ñ‚Ð½Ñ‹Ðµ Ð·Ð½Ð°Ñ‡ÐµÐ½Ð¸Ñ."
	L["reset"] = "Ð¡Ð±Ñ€Ð¾Ñ Ð¿Ñ€Ð¾Ñ„Ð¸Ð»Ñ"
	L["reset_sub"] = "Ð¡Ð±Ñ€Ð¾Ñ Ñ‚ÐµÐºÑƒÑ‰ÐµÐ³Ð¾ Ð¿Ñ€Ð¾Ñ„Ð¸Ð»Ñ Ð½Ð° ÑÑ‚Ð°Ð½Ð´Ð°Ñ€Ñ‚Ð½Ñ‹Ð¹"
	L["choose_desc"] = "Ð’Ñ‹ Ð¼Ð¾Ð¶ÐµÑ‚Ðµ ÑÐ¾Ð·Ð´Ð°Ñ‚ÑŒ Ð½Ð¾Ð²Ñ‹Ð¹ Ð¿Ñ€Ð¾Ñ„Ð¸Ð»ÑŒ, Ð²Ð²ÐµÐ´Ñ Ð½Ð°Ð·Ð²Ð°Ð½Ð¸Ðµ Ð² Ð¿Ð¾Ð»Ðµ Ð²Ð²Ð¾Ð´Ð°, Ð¸Ð»Ð¸ Ð²Ñ‹Ð±Ñ€Ð°Ñ‚ÑŒ Ð¾Ð´Ð¸Ð½ Ð¸Ð· ÑƒÐ¶Ðµ ÑÑƒÑ‰ÐµÑÑ‚Ð²ÑƒÑŽÑ‰Ð¸Ñ… Ð¿Ñ€Ð¾Ñ„Ð¸Ð»ÐµÐ¹."
	L["new"] = "ÐÐ¾Ð²Ñ‹Ð¹"
	L["new_sub"] = "Ð¡Ð¾Ð·Ð´Ð°Ñ‚ÑŒ Ð½Ð¾Ð²Ñ‹Ð¹ Ñ‡Ð¸ÑÑ‚Ñ‹Ð¹ Ð¿Ñ€Ð¾Ñ„Ð¸Ð»ÑŒ"
	L["choose"] = "Ð¡ÑƒÑ‰ÐµÑÑ‚Ð²ÑƒÑŽÑ‰Ð¸Ðµ Ð¿Ñ€Ð¾Ñ„Ð¸Ð»Ð¸"
	L["choose_sub"] = "Ð’Ñ‹Ð±Ð¾Ñ€ Ð¾Ð´Ð¸Ð½Ð¾Ð³Ð¾ Ð¸Ð· ÑƒÐ¶Ðµ Ð´Ð¾ÑÑ‚ÑƒÐ¿Ð½Ñ‹Ñ… Ð¿Ñ€Ð¾Ñ„Ð¸Ð»ÐµÐ¹"
	L["copy_desc"] = "Ð¡ÐºÐ¾Ð¿Ð¸Ñ€Ð¾Ð²Ð°Ñ‚ÑŒ Ð½Ð°ÑÑ‚Ñ€Ð¾Ð¹ÐºÐ¸ Ð¸Ð· Ð²Ñ‹Ð±Ñ€Ð°Ð½Ð½Ð¾Ð³Ð¾ Ð¿Ñ€Ð¾Ñ„Ð¸Ð»Ñ Ð² Ð°ÐºÑ‚Ð¸Ð²Ð½Ñ‹Ð¹."
	L["copy"] = "Ð¡ÐºÐ¾Ð¿Ð¸Ñ€Ð¾Ð²Ð°Ñ‚ÑŒ Ð¸Ð·"
	L["delete_desc"] = "Ð£Ð´Ð°Ð»Ð¸Ñ‚ÑŒ ÑÑƒÑ‰ÐµÑÑ‚Ð²ÑƒÑŽÑ‰Ð¸Ð¹ Ð¸ Ð½ÐµÐ¸ÑÐ¿Ð¾Ð»ÑŒÐ·ÑƒÐµÐ¼Ñ‹Ð¹ Ð¿Ñ€Ð¾Ñ„Ð¸Ð»ÑŒ Ð¸Ð· Ð‘Ð” Ð´Ð»Ñ ÑÐ¾Ñ…Ñ€Ð°Ð½ÐµÐ½Ð¸Ñ Ð¼ÐµÑÑ‚Ð°, Ð¸ Ð¾Ñ‡Ð¸ÑÑ‚Ð¸Ñ‚ÑŒ SavedVariables Ñ„Ð°Ð¹Ð»."
	L["delete"] = "Ð£Ð´Ð°Ð»Ð¸Ñ‚ÑŒ Ð¿Ñ€Ð¾Ñ„Ð¸Ð»ÑŒ"
	L["delete_sub"] = "Ð£Ð´Ð°Ð»ÐµÐ½Ð¸Ðµ Ð¿Ñ€Ð¾Ñ„Ð¸Ð»Ñ Ð¸Ð· Ð‘Ð”"
	L["delete_confirm"] = "Ð’Ñ‹ ÑƒÐ²ÐµÑ€ÐµÐ½Ñ‹, Ñ‡Ñ‚Ð¾ Ð²Ñ‹ Ñ…Ð¾Ñ‚Ð¸Ñ‚Ðµ ÑƒÐ´Ð°Ð»Ð¸Ñ‚ÑŒ Ð²Ñ‹Ð±Ñ€Ð°Ð½Ð½Ñ‹Ð¹ Ð¿Ñ€Ð¾Ñ„Ð¸Ð»ÑŒ?"
	L["profiles"] = "ÐŸÑ€Ð¾Ñ„Ð¸Ð»Ð¸"
	L["profiles_sub"] = "Ð£Ð¿Ñ€Ð°Ð²Ð»ÐµÐ½Ð¸Ðµ Ð¿Ñ€Ð¾Ñ„Ð¸Ð»ÑÐ¼Ð¸"
	--L["current"] = "Current Profile:"
end

local defaultProfiles
local tmpprofiles = {}

-- Get a list of available profiles for the specified database.
-- You can specify which profiles to include/exclude in the list using the two boolean parameters listed below.
-- @param db The db object to retrieve the profiles from
-- @param common If true, getProfileList will add the default profiles to the return list, even if they have not been created yet
-- @param nocurrent If true, then getProfileList will not display the current profile in the list
-- @return Hashtable of all profiles with the internal name as keys and the display name as value.
local function getProfileList(db, common, nocurrent)
	local profiles = {}
	
	-- copy existing profiles into the table
	local currentProfile = db:GetCurrentProfile()
	for i,v in pairs(db:GetProfiles(tmpprofiles)) do 
		if not (nocurrent and v == currentProfile) then 
			profiles[v] = v 
		end 
	end
	
	-- add our default profiles to choose from ( or rename existing profiles)
	for k,v in pairs(defaultProfiles) do
		if (common or profiles[k]) and not (nocurrent and k == currentProfile) then
			profiles[k] = v
		end
	end
	
	return profiles
end

--[[
	OptionsHandlerPrototype
	prototype class for handling the options in a sane way
]]
local OptionsHandlerPrototype = {}

--[[ Reset the profile ]]
function OptionsHandlerPrototype:Reset()
	self.db:ResetProfile()
end

--[[ Set the profile to value ]]
function OptionsHandlerPrototype:SetProfile(info, value)
	self.db:SetProfile(value)
end

--[[ returns the currently active profile ]]
function OptionsHandlerPrototype:GetCurrentProfile()
	return self.db:GetCurrentProfile()
end

--[[ 
	List all active profiles
	you can control the output with the .arg variable
	currently four modes are supported
	
	(empty) - return all available profiles
	"nocurrent" - returns all available profiles except the currently active profile
	"common" - returns all avaialble profiles + some commonly used profiles ("char - realm", "realm", "class", "Default")
	"both" - common except the active profile
]]
function OptionsHandlerPrototype:ListProfiles(info)
	local arg = info.arg
	local profiles
	if arg == "common" and not self.noDefaultProfiles then
		profiles = getProfileList(self.db, true, nil)
	elseif arg == "nocurrent" then
		profiles = getProfileList(self.db, nil, true)
	elseif arg == "both" then -- currently not used
		profiles = getProfileList(self.db, (not self.noDefaultProfiles) and true, true)
	else
		profiles = getProfileList(self.db)
	end
	
	return profiles
end

function OptionsHandlerPrototype:HasNoProfiles(info)
	local profiles = self:ListProfiles(info)
	return ((not next(profiles)) and true or false)
end

--[[ Copy a profile ]]
function OptionsHandlerPrototype:CopyProfile(info, value)
	self.db:CopyProfile(value)
end

--[[ Delete a profile from the db ]]
function OptionsHandlerPrototype:DeleteProfile(info, value)
	self.db:DeleteProfile(value)
end

--[[ fill defaultProfiles with some generic values ]]
local function generateDefaultProfiles(db)
	defaultProfiles = {
		["Default"] = L["default"],
		[db.keys.char] = db.keys.char,
		[db.keys.realm] = db.keys.realm,
		[db.keys.class] = UnitClass("player")
	}
end

--[[ create and return a handler object for the db, or upgrade it if it already existed ]]
local function getOptionsHandler(db, noDefaultProfiles)
	if not defaultProfiles then
		generateDefaultProfiles(db)
	end
	
	local handler = AceDBOptions.handlers[db] or { db = db, noDefaultProfiles = noDefaultProfiles }
	
	for k,v in pairs(OptionsHandlerPrototype) do
		handler[k] = v
	end
	
	AceDBOptions.handlers[db] = handler
	return handler
end

--[[
	the real options table 
]]
local optionsTable = {
	desc = {
		order = 1,
		type = "description",
		name = L["intro"] .. "\n",
	},
	descreset = {
		order = 9,
		type = "description",
		name = L["reset_desc"],
	},
	reset = {
		order = 10,
		type = "execute",
		name = L["reset"],
		desc = L["reset_sub"],
		func = "Reset",
	},
	current = {
		order = 11,
		type = "description",
		name = function(info) return L["current"] .. " " .. NORMAL_FONT_COLOR_CODE .. info.handler:GetCurrentProfile() .. FONT_COLOR_CODE_CLOSE end,
		width = "default",
	},
	choosedesc = {
		order = 20,
		type = "description",
		name = "\n" .. L["choose_desc"],
	},
	new = {
		name = L["new"],
		desc = L["new_sub"],
		type = "input",
		order = 30,
		get = false,
		set = "SetProfile",
	},
	choose = {
		name = L["choose"],
		desc = L["choose_sub"],
		type = "select",
		order = 40,
		get = "GetCurrentProfile",
		set = "SetProfile",
		values = "ListProfiles",
		arg = "common",
	},
	copydesc = {
		order = 50,
		type = "description",
		name = "\n" .. L["copy_desc"],
	},
	copyfrom = {
		order = 60,
		type = "select",
		name = L["copy"],
		desc = L["copy_desc"],
		get = false,
		set = "CopyProfile",
		values = "ListProfiles",
		disabled = "HasNoProfiles",
		arg = "nocurrent",
	},
	deldesc = {
		order = 70,
		type = "description",
		name = "\n" .. L["delete_desc"],
	},
	delete = {
		order = 80,
		type = "select",
		name = L["delete"],
		desc = L["delete_sub"],
		get = false,
		set = "DeleteProfile",
		values = "ListProfiles",
		disabled = "HasNoProfiles",
		arg = "nocurrent",
		confirm = true,
		confirmText = L["delete_confirm"],
	},
}

--- Get/Create a option table that you can use in your addon to control the profiles of AceDB-3.0.
-- @param db The database object to create the options table for.
-- @return The options table to be used in AceConfig-3.0
-- @usage 
-- -- Assuming `options` is your top-level options table and `self.db` is your database:
-- options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
function AceDBOptions:GetOptionsTable(db, noDefaultProfiles)
	local tbl = AceDBOptions.optionTables[db] or {
			type = "group",
			name = L["profiles"],
			desc = L["profiles_sub"],
		}
	
	tbl.handler = getOptionsHandler(db, noDefaultProfiles)
	tbl.args = optionsTable

	AceDBOptions.optionTables[db] = tbl
	return tbl
end

-- upgrade existing tables
for db,tbl in pairs(AceDBOptions.optionTables) do
	tbl.handler = getOptionsHandler(db)
	tbl.args = optionsTable
end
