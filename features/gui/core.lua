local Public = require 'features.gui.main'

local Inputs = require 'features.gui.templates.inputs'
Public.inputs = Inputs
Public.classes.Inputs = Inputs

local Toolbar = require 'features.gui.templates.toolbar'
Public.toolbar = Toolbar
Public.classes.Toolbar = Toolbar

local Center = require 'features.gui.templates.center'
Public.center = Center
Public.classes.Center = Center

local Left = require 'features.gui.templates.left'
Public.left = Left
Public.classes.Left = Left

local Popup = require 'features.gui.templates.popup'
Public.popup = Popup
Public.classes.Popup = Popup

return Public