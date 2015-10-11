Attribute VB_Name = "ckaiis_globals"
Option Explicit

Public d3 As New d3
Public Pick As New Pick
Public g_delimiters(3) As String * 1
Public g_drive As String  'mco 16sep00
Public Const g_template_file = "/prospect/template/"
Public g_trans_info_array() As String
Public g_rates() As String
Public g_dates() As String 'mc12may99
Public g_ptab As String 'used in SR1694 then in SR1625_PENALTY
Public g_heading_name As String
Public g_colTemplates() As String  'RGM 7Oct99 for contents of templates
Public g_colTempnames() As String  'RGM 7Oct99 for names of templates

'RGM Used for finding files
Public Const MAX_PATH = 260
Public Const INVALID_HANDLE_VALUE = -1
Public Const FILE_ATTRIBUTE_DIRECTORY = &H10

Public Type FILETIME
   dwLowDateTime As Long
   dwHighDateTime As Long
End Type

Public Type WIN32_FIND_DATA
   dwFileAttributes As Long
   ftCreationTime As FILETIME
   ftLastAccessTime As FILETIME
   ftLastWriteTime As FILETIME
   nFileSizeHigh As Long
   nFileSizeLow As Long
   dwReserved0 As Long
   dwReserved1 As Long
   cFileName As String * MAX_PATH
   cAlternate As String * 14
End Type

Public Declare Function FindFirstFile Lib "kernel32" Alias "FindFirstFileA" (ByVal lpFileName As String, lpFindFileData As WIN32_FIND_DATA) As Long
Public Declare Function FindNextFile Lib "kernel32" Alias "FindNextFileA" (ByVal hFindFile As Long, lpFindFileData As WIN32_FIND_DATA) As Long
Public Declare Function FindClose Lib "kernel32" (ByVal hFindFile As Long) As Long

