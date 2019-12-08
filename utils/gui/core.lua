local Public = require 'utils.gui.main'

local Inputs = require 'utils.gui.templates.inputs'
Public.inputs = Inputs
Public.classes.Inputs = Inputs

local Toolbar = require 'utils.gui.templates.toolbar'
Public.toolbar = Toolbar
Public.classes.Toolbar = Toolbar

local Center = require 'utils.gui.templates.center'
Public.center = Center
Public.classes.Center = Center

local Left = require 'utils.gui.templates.left'
Public.left = Left
Public.classes.Left = Left

local Popup = require 'utils.gui.templates.popup'
Public.popup = Popup
Public.classes.Popup = Popup

return Public