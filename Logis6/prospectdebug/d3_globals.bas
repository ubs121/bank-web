Attribute VB_Name = "d3_globals"
Option Explicit
Option Compare Text

Public g_d3Environment As clsD3Environment
Public g_d3domain As clsD3NetDomain
Public g_d3VME As clsD3VirtualMachine
Public g_d3rulecatalog As clsD3RuleCatalog
Public g_d3rulemodules() As clsD3RuleModule
Public g_d3rulemodule_names() As String
Public g_d3_databases() As clsD3Database
Public g_d3_dbnames() As String
Public g_d3_maxDb As Integer
Public g_d3_maxtable As Integer
Public g_Mydatabase As clsD3Database
Public g_trans_info As String  'mc 29apr99
Public g_database As String 'mco 16mar00
Public g_UserID As String
Public g_UserPW As String
