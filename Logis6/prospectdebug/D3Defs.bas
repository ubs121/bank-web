Attribute VB_Name = "basD3Defs"

' Global D3 Constants
' ===================
' This module is reserved and should not be modified.
'
' (use  '; // comment  at the end of each line )
'
' [001] 05Aug96 MNB: Added unknow system error as maximum error code 4095.
' [002] 12Aug96 MNB: Fixed d3MiscErr_NotImp was colliding with _Internal.
' [003] 21Sep96 MNB: Added BadVmeHandle, BadTclHandle, BadCatHandle.
' [004] 09Oct96 MNB: Added Hex(D3Magic), D3NoHandle, and D3 Object types as strings.
'                    They should numbers and equated in the enum in PickObj.h,
'                    and converted to strings in within VB. Oh well for now.
'       10Oct96 MNB: Const Strings not supported in VC++, so translated D3Defs.h
'                    would not compile. Eric commented out my changes until I
'                    could do them as described above.
' [005] 16Oct96 MNB: Added constants for clsD3TclCommand brResults and
'                    clsD3Environment brTclFlags and clsD3VirtualMachine brSystem(15).
' [006] 08Nov96 MNB: Added more constants for VB and error reporting
' [007] 19Nov96 es:  Added BMR errors
' [008] 21Nov96 MNB: Added more VB constants
' [009] 14Apr97 es:  Added d3FsiErr_FileDeleted
' [010] 19Apr97 es:  Added errors for VME logons
' [011] 22Apr97 es:  Added rpc server disconnected error
' [012] 09Sep97 es:      Added resizing execptions
' [005]...
' clsD3TclCommand/clsD3VirtualMachine brResults values
Public Const D3ExecuteNoResults = 0 '; // Neither
Public Const D3ExecuteCapturing = 1 '; // Capturing only
Public Const D3ExecuteReturning = 2 '; // Returning only
Public Const D3ExecuteWithBoth = 3  '; // Capturing and Returning

' clsD3Envronment brTclFlags and clsD3VirtualMachine brSystem(15)
Public Const D3TclFlag_AFlg = -2147483647   '; // 0x80000000 Abort on error
Public Const D3TclFlag_DFlg = 268435456     '; // 0x10000000 Debug immediate
Public Const D3TclFlag_EFlg = 134217728     '; // 0x08000000 Error go debug
Public Const D3TclFlag_SFlg = 8192          '; // 0x00002000 Suppress ErrMsg
' Other flags AFlg - ZFlg can also be defined.
' ...[005]

' [008]...
' clsD3DynamicArray delimeters  *** Note: Must use Chr$(n) ***
Public Const D3SM = 255                     '; // Segment Mark
Public Const D3AM = 254                     '; // Attribute Mark
Public Const D3VM = 253                     '; // Value Mark
Public Const D3SVM = 252                    '; // Sub Value Mark
Public Const D3SB = 251                     '; // Start Buffer

' clsD3File brCreateIndex() values
Public Const D3ReplaceIndex = True          '; // bOverwrite
Public Const D3PreserveIndex = False        '; // bOverwrite
Public Const D3EntireIndex = True           '; // bEntirety
Public Const D3PartialIndex = False         '; // bEntirety

' clsD3Index brKey() values     *** Note: Must use Chr$(n) ***
Public Const D3IndexCompKey = 67            '; // brKey("C"), brFindFirst()
Public Const D3IndexLastKey = 76            '; // brKey("L"), brFindLast()
Public Const D3IndexNextKey = 78            '; // brKey("N"), brFindNext()
Public Const D3IndexPrevKey = 80            '; // brKey("P"), brFindPrevious()
Public Const D3IndexRtrnKey = 82            '; // brKey("R")
Public Const D3IndexVrfyKey = 86            '; // brKey("V")
Public Const D3IndexXtraKey = 88            '; // brKeyX()

' clsD3VirtualMachine brSelect() values
Public Const D3SelectPrimary = False        '; // vbSecondary
Public Const D3SelectSecondary = True       '; // vbSecondary
' ...[008]

' [004]...
' Magic word that flags this as a D3 object handle
Public Const D3Magic = 54077        '; // xD33D
' Class word (major/minor nibbles) type of object
Public Const D3ClassDA = 272        '; // x0110 1 aPickItem
Public Const D3ClassRM = 274        '; // x0112 2 aPBModule
Public Const D3ClassSL = 275        '; // x0113 3 aPickList
Public Const D3ClassFV = 512        '; // x0200 4 aPickFile (abstract)
Public Const D3ClassVM = 771        '; // x0303 5 aPickRpc
Public Const D3ClassTCL = 771       '; // x0303 6 aPickRpc
Public Const D3ClassDB = 2048       '; // x0800 7 aPickDatabase
Public Const D3ClassND = 2304       '; // x0900 8 aPickDomain
Public Const D3ClassDE = 61696      '; // xf100 9 clsD3Environement
Public Const D3ClassConn = 61952    '; // xf200 a clsD3Connection (super object)
Public Const D3ClassSA = 62208      '; // xf300 b clsD3StaticArray
Public Const D3ClassTTY = 62464     '; // xf400 c clsD3TtyManager
Public Const D3ClassTD = 62720      '; // xf500 d clsD3TapeDevice
Public Const D3ClassBT = 62976      '; // xf600 e clsD3BTreeIndex
Public Const D3ClassRC = 63232      '; // xf700 f clsD3RuleCatalog
' Empty long indicates no valid handle to object.
Public Const D3NoHandle = 0         '; // x00000000
' ...[004]

Public Const brDeadRule = 0         '; //
Public Const brLocalRule = 1        '; //
Public Const brRemoteRule = -1      '; //

Public Const brTrue = True          '; //
Public Const brFalse = False        '; //

' D3 General Constants
' ====================
Public Const d3Nothing = 0          '; //

' D3 File constants
' =================
Public Const d3File_AcntLevel = 1               '; //
Public Const d3File_DictLevel = 2               '; //
Public Const d3File_DataLevel = 3               '; //
Public Const d3File_Direct = 1                  '; //
Public Const d3File_Hashed = 0                  '; //
Public Const d3File_FrameSize = 4096            '; //
Public Const d3File_Ansi = False                '; //
Public Const d3File_Unicode = True              '; //
Public Const d3File_CaseSensitive = False       '; //
Public Const d3File_CaseInsensitive = True      '; //

' D3 Item constants
Public Const D3Item_NoWaiting = 0           '; // False/NoTime
Public Const D3Item_AmWaiting = -1          '; // True/Forever
Public Const D3Item_ReadLocked = True       '; // ReadU
Public Const d3Item_ReadNoLock = False      '; // Read
Public Const d3Item_WriteUnlock = True      '; // Write
Public Const d3Item_WriteNoLock = False     '; // Write{U}

' D3 NT List constants
Public Const d3List_TypeNone = -1   '; // Initialize
Public Const d3List_TypeAcnt = 0    '; // d3ND.Select
Public Const d3List_TypeFile = 1    '; // d3DB.Select  (d3DB.SelectDict(d3FV))
Public Const d3List_TypeDict = 2    '; // d3FV.Select
Public Const d3List_TypeItem = 3    '; // d3DA.Select
Public Const d3List_TypeTCL = 4     '; // d3TCL.Select

' D3 Exceptions Classes
' =====================
' Exceptions classes must NOT exceeed 11
Public Const d3SrvClsErr = 0         '; // Common services errors
Public Const d3MiscClsErr = 1        '; // Misc errors
Public Const d3FsiClsErr = 2         '; // D3/NT File System
Public Const d3VmeClsErr = 3         '; // D3/NT VME
Public Const d3BrmClsErr = 4         '; // D3/NT Business Rule Module
Public Const d3RpcClsErr = 5         '; // D3/NT RPC
Public Const d3RegClsErr = 6         '; // D3/NT Registry
Public Const d3TapeClsErr = 7        '; // D3/NT Tape
Public Const d3SpoolClsErr = 8       '; // D3/NT Spooler
Public Const d3StrClsErr = 9         '; // D3/NT String exception
Public Const d3VirtClsErr = 10       '; // D3/NT Virtual exception (place holder)
Public Const d3SysClsErr = 11        '; // D3/NT Underlying Host exception


' D3 Exceptions Values
' ====================
Public Const d3BaseErr = 1024        '; // Base of D3 error codes
Public Const d3SrvErr = vbObjectError + d3BaseErr + 0           '; // Common server errors
Public Const d3MiscErr = vbObjectError + d3BaseErr + d3MiscClsErr * 256 '; // Misc errors
Public Const d3FsiErr = vbObjectError + d3BaseErr + d3FsiClsErr * 256   '; // D3/NT File System
Public Const d3VmeErr = vbObjectError + d3BaseErr + d3VmeClsErr * 256   '; // D3/NT VME
Public Const d3BrmErr = vbObjectError + d3BaseErr + d3BrmClsErr * 256   '; // D3/NT Business Rule Module
Public Const d3RpcErr = vbObjectError + d3BaseErr + d3RpcClsErr * 256   '; // D3/NT RPC
Public Const d3RegErr = vbObjectError + d3BaseErr + d3RegClsErr * 256   '; // D3/NT Registry
Public Const d3TapeErr = vbObjectError + d3BaseErr + d3TapeClsErr * 256  '; // D3/NT Tape
Public Const d3SpoolErr = vbObjectError + d3BaseErr + d3SpoolClsErr * 256 '; // D3/NT Spooler
Public Const d3StrErr = vbObjectError + d3BaseErr + d3StrClsErr * 256   '; // D3/NT Strings
Public Const d3VirtErr = vbObjectError + d3BaseErr + d3VirtClsErr * 256 '; // D3/NT Virtual
Public Const d3SysErr = vbObjectError + d3BaseErr + d3SysClsErr * 256 '; // D3/NT System


' D3 General Service Errors
' =========================
' These errors are the most likely errors to be found in a VB app
Public Const d3SrvErr_NFile = d3SrvErr + 1      '; //  Too many opened files
Public Const d3SrvErr_Access = d3SrvErr + 2     '; //  Item not present or no access to it
Public Const d3SrvErr_Lock = d3SrvErr + 5       '; //  File/Item is locked
Public Const d3SrvErr_Inval = d3SrvErr + 6      '; //  invalid Call
Public Const d3SrvErr_NoNum = d3SrvErr + 7      '; //  Not a Number
Public Const d3SrvErr_BadF = d3SrvErr + 8       '; //  File not opened
Public Const d3SrvErr_Missing = d3SrvErr + 9    '; //  File not present
Public Const d3SrvErr_Conv = d3SrvErr + 10      '; //  Conversion Error
Public Const d3SrvErr_BadCol = d3SrvErr + 11    '; //  Bad column Number/Name
Public Const d3SrvErr_EOF = d3SrvErr + 15       '; //  Reached end-of-file/item
Public Const d3SrvErr_CallMain = d3SrvErr + 17  '; //  Tried to call main as sub
Public Const d3SrvErr_NotRoot = d3SrvErr + 19   '; //  No index found on root statement
Public Const d3SrvErr_NoIndexId = d3SrvErr + 22 '; //  No more index entries
Public Const d3SrvErr_BadParams = d3SrvErr + 34 '; //  Wrong parameter number
Public Const d3SrvErr_EndList = d3SrvErr + 36   '; //  End of List


' D3 Miscellaneous Errors
' =======================
Public Const d3MiscErr_Internal = d3MiscErr + 1 '; //  Internal Library Failure
Public Const d3MiscErr_NotImp = d3MiscErr + 2   '; //  [002] Not Implemented
Public Const d3MiscErr_ODBC = d3MiscErr + 3     '; //  Domain must be "ODBC;"
Public Const d3MiscErr_Misc = d3MiscErr + 99    '; //  Misc Error


' D3/NT File System Interface Errors
' ==================================
' Most 'normal' exceptions from the FSI are reported as 'General Services Errors'
' The following codes are normally trapped by the underlying OCX or automation
' servers.
Public Const d3FsiErr_FcbMissing = d3FsiErr + 3                 '; // No FCB for the file
Public Const d3FsiErr_FileExist = d3FsiErr + 6                  '; // File already exist
Public Const d3FsiErr_FileOpenError = d3FsiErr + 7              '; // Underlying IO error
Public Const d3FsiErr_FileCreateError = d3FsiErr + 8            '; // Underlying IO error
Public Const d3FsiErr_FileDeleteError = d3FsiErr + 9            '; // Underlying IO error
Public Const d3FsiErr_FileReadError = d3FsiErr + 10             '; // Underlying IO error
Public Const d3FsiErr_FileWriteError = d3FsiErr + 11            '; // Underlying IO error
Public Const d3FsiErr_FileExtendError = d3FsiErr + 12           '; // File size increase error
Public Const d3FsiErr_FileSeekError = d3FsiErr + 13                     '; // Seek in file error
Public Const d3FsiErr_AccountMissing = d3FsiErr + 14            '; // Database/Account missing
Public Const d3FsiErr_NotDptr = d3FsiErr + 15                           '; // Item is not a D ptr
Public Const d3FsiErr_AccountExist = d3FsiErr + 16                      '; // Cannt create account
Public Const d3FsiErr_FileTooLarge = d3FsiErr + 17                      '; // Not permitted
Public Const d3FsiErr_FileStillOpened = d3FsiErr + 18           '; // File is still opened
Public Const d3FsiErr_FileMappingError = d3FsiErr + 19          '; // View mapping error
Public Const d3FsiErr_CreateFileMappingError = d3FsiErr + 20 '; // Create file mapping error
Public Const d3FsiErr_ItemTruncated = d3FsiErr + 21                     '; // Large item as truncated
Public Const d3FsiErr_TooManyExtensions = d3FsiErr + 22         '; // Mapped file was extended too many times
Public Const d3FsiErr_DptrDeleteError = d3FsiErr + 23           '; // Cannot delete D pointer
Public Const d3FsiErr_TooManyClients = d3FsiErr + 24            '; // Exceeded licensed clients
Public Const d3FsiErr_ObsoleteFsiVersion = d3FsiErr + 25        '; // Old fsi version
Public Const d3FsiErr_FileInUse = d3FsiErr + 26                         '; // Cannot lock file for exclusive access
Public Const d3FsiErr_FileRenameError = d3FsiErr + 27           '; // Cannot rename file
Public Const d3FsiErr_FilesNotOnSameServer = d3FsiErr + 28      '; // Operation requires files to be on same server
Public Const d3FsiErr_CreateDirectoryError = d3FsiErr + 30      '; // Failed to create a directory
Public Const d3FsiErr_NoMds = d3FsiErr + 31                                     '; // Cannot find any MDS
Public Const d3FsiErr_CorruptedCellLength = d3FsiErr + 32 '; // Corrupted group
Public Const d3FsiErr_DeleteMissingFile = d3FsiErr + 33         '; // Attempt to delete a missing file (ok)
Public Const d3FsiErr_DeleteMissingAccount = d3FsiErr + 34      '; // Attempt to delete a missing account (ok)
Public Const d3FsiErr_CallCorrMissing = d3FsiErr + 35           '; // Missing sub in a CALL file correlative
Public Const d3FsiErr_CallCorrError = d3FsiErr + 36             '; // Sub error in a CALL file correlative
Public Const d3FsiErr_MaxQptrDepth = d3FsiErr + 37              '; // Sub error in a CALL file correlative
Public Const d3FsiErr_ServerNameMissing = d3FsiErr + 38         '; // Need Server Name to open RPC
Public Const d3FsiErr_FileDeleted = d3FsiErr + 39                       '; // File was deleted
Public Const d3FsiErr_FileResizing = d3FsiErr + 40                      '; // File is being resized
Public Const d3FsiErr_FileMovedInUse = d3FsiErr + 41                    '; // File moved is being used
Public Const d3FsiErr_FileMovedError = d3FsiErr + 42                    '; // Cannot copy the same item in the same file
Public Const d3FsiErr_AbortOperation = d3FsiErr + 43                    '; // Trigger abort operation


' D3OleCtl.OCX (only) throws these
Public Const d3FsiErr_BadNtwkHandle = d3FsiErr + 101                    '; // Null NetDomain handle
Public Const d3FsiErr_BadAcntHandle = d3FsiErr + 102                    '; //      Database handle
Public Const d3FsiErr_BadFileHandle = d3FsiErr + 103                    '; //       File Var. handle
Public Const d3FsiErr_BadItemHandle = d3FsiErr + 104                    '; //       aPickItem handle
Public Const d3FsiErr_BadListHandle = d3FsiErr + 105                    '; //       Select List handle
Public Const d3FsiErr_BadRootHandle = d3FsiErr + 106                    '; //      BTree Root handle
Public Const d3FsiErr_BadRuleHandle = d3FsiErr + 107                    '; //       Rule Module handle
Public Const d3FsiErr_BadStrgHandle = d3FsiErr + 108                    '; //      aPickString handle
Public Const d3FsiErr_BadFlatHandle = d3FsiErr + 109                    '; //      Static Array handle
Public Const d3FsiErr_BadAmCount = d3FsiErr + 110                       '; //
Public Const d3FsiErr_BadVmCount = d3FsiErr + 111                       '; //
Public Const d3FsiErr_BadSvmCount = d3FsiErr + 112                      '; //
Public Const d3FsiErr_BadVmeHandle = d3FsiErr + 113                     '; // [003]
Public Const d3FsiErr_BadTclHandle = d3FsiErr + 113                     '; // [003]
Public Const d3FsiErr_BadCatHandle = d3FsiErr + 113                     '; // [003]



' D3 VME Errors
' =============
' These errors are normally not seen by VB applications.
Public Const d3VmeErr_UdefDllEntry = d3VmeErr + 1                       '; // Missing entry table in  DLL
Public Const d3VmeErr_UdefDll = d3VmeErr + 2                            '; // Missing DLL
Public Const d3VmeErr_MutexPibsCreateError = d3VmeErr + 3       '; // Failed to create PIBS mutex
Public Const d3VmeErr_MutexPibsWaitError = d3VmeErr + 4         '; // Failed to wait on PIBS mutex
Public Const d3VmeErr_MutexPibsWaitTimeout = d3VmeErr + 5       '; // Timed out on gettting lock on pibs
Public Const d3VmeErr_MutexPibsReleaseError = d3VmeErr + 6      '; // Fialed to release pibs mutex
Public Const d3VmeErr_DiskError = d3VmeErr + 7                          '; // Disk error
Public Const d3VmeErr_NoFreePib = d3VmeErr + 8                          '; // All pibs are busy
Public Const d3VmeErr_AlreadyExists = d3VmeErr + 9                      '; // VME is already started or initialized
Public Const d3VmeErr_NotAPickProcess = d3VmeErr + 10 '; // The thread has no pick object
Public Const d3VmeErr_BadPib = d3VmeErr + 11 '; // invalid PIB
Public Const d3VmeErr_GetConsoleModeError = d3VmeErr + 12 '; // Cannot get the console mode
Public Const d3VmeErr_SetConsoleModeError = d3VmeErr + 13 '; // Cannot program the console
Public Const d3VmeErr_InvalidConsole = d3VmeErr + 14 '; // Cannot get handles to stdin/out
Public Const d3VmeErr_TLSAllocError = d3VmeErr + 15 '; // Cannot allocate TLS
Public Const d3VmeErr_TLSSetError = d3VmeErr + 16 '; // Cannot store data in TLS
Public Const d3VmeErr_TLSNotSet = d3VmeErr + 17 '; // TLS not initialized
Public Const d3VmeErr_EventCreateError = d3VmeErr + 18 '; // Event creation error
Public Const d3VmeErr_BadPibSetProcess = d3VmeErr + 19 '; // No PCB attached to an object
Public Const d3VmeErr_UdefMode = d3VmeErr + 20 '; // Undefined call to a mode
Public Const d3VmeErr_ComOpenFail = d3VmeErr + 22 '; // Cannot open COM port
Public Const d3VmeErr_ComIOError = d3VmeErr + 23 '; // COM IO error
Public Const d3VmeErr_PrinterError = d3VmeErr + 24 '; // Printer parameter error
Public Const d3VmeErr_AbortedShutdown = d3VmeErr + 25 '; // Shutdown was aborted
Public Const d3VmeErr_RemoteNotSup = d3VmeErr + 26 '; // Not suported on remote connections
Public Const d3VmeErr_NtLogonErr = d3VmeErr + 27 ';   // Illegal NT user/pwd
Public Const d3VmeErr_MissingUsersFile = d3VmeErr + 28 ';  // Missing shared users file
Public Const d3VmeErr_RemoteIOError = d3VmeErr + 29 ';  // Remote Master IO process not found
Public Const d3VmeErr_DeviceBusy = d3VmeErr + 30 ';  // Remote Master IO device busy

' D3 RPC Errors
' =============
' These errors are normally not visible from a user VB application. They
' may be used by some system applets
Public Const d3RpcErr_SetServiceStatusError = d3RpcErr + 1                      '; // Cannot update status
Public Const d3RpcErr_StartDispatcherError = d3RpcErr + 2                       '; // Cannot start Service Control Dispatcher
Public Const d3RpcErr_CannotInstall = d3RpcErr + 3                                      '; // Generic " Unable to install Service"
Public Const d3RpcErr_OpenServiceError = d3RpcErr + 4                           '; // Cannot open service
Public Const d3RpcErr_OpenSCManagerError = d3RpcErr + 5                         '; // Cannot access Service Control Manager
Public Const d3RpcErr_CreateServiceError = d3RpcErr + 6                         '; // Cannot create service
Public Const d3RpcErr_BindingError = d3RpcErr + 7                                       '; // Binding error
Public Const d3RpcErr_ComposeError = d3RpcErr + 8                                       '; // StringBindingCompose error
Public Const d3RpcErr_RegisterIfError = d3RpcErr + 9                            '; // Cannot register interface
Public Const d3RpcErr_InqBindingErr = d3RpcErr + 10                                     '; // Inq Binding error
Public Const d3RpcErr_BindingExportErr = d3RpcErr + 11                          '; // Export binding failed
Public Const d3RpcErr_BindingUnexportErr = d3RpcErr + 12                        '; // UnExport binding failed
Public Const d3RpcErr_BindinVectorFreeErr = d3RpcErr + 13                       '; // Cannot free binding vector
Public Const d3RpcErr_BindingImportError = d3RpcErr + 14                        '; // Import from name service error
Public Const d3RpcErr_WaitServerListenError = d3RpcErr + 15                     '; // RpcMgmtWaitServerListenError
Public Const d3RpcErr_NoBinding = d3RpcErr + 16                                         '; // Cannot get a valid binding handle
Public Const d3RpcErr_RtException = d3RpcErr + 17                                       '; // RPC run time exception
Public Const d3RpcErr_NoProtocol = d3RpcErr + 18                                        '; // No available protocol
Public Const d3RpcErr_ListenError = d3RpcErr + 19                                       '; // RpcServerListen error
Public Const d3RpcErr_EpRegisterError = d3RpcErr + 20                           '; // RpcEpRegister Error
Public Const d3RpcErr_UnregisterIfErr = d3RpcErr + 21                           '; // RpcUnregisterIf error
Public Const d3RpcErr_MultipleInstance = d3RpcErr + 22                          '; // Multiple instance of server
Public Const d3RpcErr_ServerLock = d3RpcErr + 23                                        '; // Global server mutex locked
Public Const d3RpcErr_ServerUnlock = d3RpcErr + 24                                      '; // Failed to release server mutex
Public Const d3RpcErr_StartServiceError = d3RpcErr + 25                         '; // Cannot start service
Public Const d3RpcErr_DeleteServiceError = d3RpcErr + 26                        '; // Cannot delete service
Public Const d3RpcErr_ServerNotActivated = d3RpcErr + 27                        '; // Cannot delete service
Public Const d3RpcErr_ServerDisconnected = d3RpcErr + 28                        '; // Got disconnected


' D3 Host System Errors
' =====================
Public Const d3SysErr_MissingVersId = d3SysErr + 1      '; // Missing resource id in .exe
Public Const d3SysErr_TlsAllocation = d3SysErr + 2      '; // Can not allocate Thread Local Storage
Public Const d3SysErr_TlsGet = d3SysErr + 3             '; // Can not access Thread Local Storage
Public Const d3SysErr_TlsSet = d3SysErr + 4             '; // Can not update Thread Local Storage
Public Const d3SysErr_OutOfmemory = d3SysErr + 5        '; // Cannot allocate memory

Public Const d3SysErr_Obsolete = d3SysErr + 252         '; // [006] 4092, or -4 or x7FC
Public Const d3SysErr_NotImp = d3SysErr + 253           '; // [006] 4093, or -3 or x7FD
Public Const d3SysErr_Reserved = d3SysErr + 254         '; // [006] 4094, or -2 or x7FE
Public Const d3SysErr_Unknown = d3SysErr + 255          '; // [001] 4095, or -1 or x7FF


' D3 Flash Interpreter Errors
' ===========================
Public Const d3BrmErr_AllocPbError = d3BrmErr + 1   '; // Failed to allocate memory
Public Const d3BrmErr_RelocPbError = d3BrmErr + 2   '; // Relocation error
Public Const d3BrmErr_UnhandledDebugInput = d3BrmErr + 3  '; // Runtime class does not support debugger input
Public Const d3BrmErr_UnhandledInput = d3BrmErr + 4 '; // Runtime class does not support input
Public Const d3BrmErr_MissingObject = d3BrmErr + 5  '; // No flash object

