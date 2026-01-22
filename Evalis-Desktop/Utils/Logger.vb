Imports System.IO
Imports System.Text
Imports System.Runtime.CompilerServices

Namespace Utils

    ''' <summary>
    ''' Defines the severity levels for log messages.
    ''' </summary>
    Public Enum LogLevel
        Debug = 0
        Info = 1
        Warning = 2
        [Error] = 3
    End Enum

    ''' <summary>
    ''' Provides centralized, thread-safe logging functionality for the EvAlis application.
    ''' Implements a singleton pattern with daily log file rotation.
    ''' </summary>
    ''' <remarks>
    ''' Log files are stored in: %LOCALAPPDATA%\EvAlis\Logs\
    ''' Format: evalis_yyyy-MM-dd.log
    ''' </remarks>
    Public Class Logger

#Region "Singleton"

        Private Shared _instance As Logger
        Private Shared ReadOnly _singletonLock As New Object()

        ''' <summary>
        ''' Gets the singleton instance of the Logger.
        ''' </summary>
        Public Shared ReadOnly Property Instance As Logger
            Get
                If _instance Is Nothing Then
                    SyncLock _singletonLock
                        If _instance Is Nothing Then
                            _instance = New Logger()
                        End If
                    End SyncLock
                End If
                Return _instance
            End Get
        End Property

        ''' <summary>
        ''' Private constructor to enforce singleton pattern.
        ''' </summary>
        Private Sub New()
            _minimumLevel = LogLevel.Debug
            _logDirectory = GetDefaultLogDirectory()
            EnsureLogDirectoryExists()
            UpdateLogFile()
        End Sub

#End Region

#Region "Configuration"

        Private _minimumLevel As LogLevel
        Private _logDirectory As String
        Private _currentLogFile As String
        Private _currentDate As Date
        Private ReadOnly _writeLock As New Object()

        ''' <summary>
        ''' Gets or sets the minimum log level. Messages below this level will not be logged.
        ''' </summary>
        Public Property MinimumLevel As LogLevel
            Get
                Return _minimumLevel
            End Get
            Set(value As LogLevel)
                _minimumLevel = value
            End Set
        End Property

        ''' <summary>
        ''' Gets the directory where log files are stored.
        ''' </summary>
        Public ReadOnly Property LogDirectory As String
            Get
                Return _logDirectory
            End Get
        End Property

        ''' <summary>
        ''' Gets the path to the current log file.
        ''' </summary>
        Public ReadOnly Property CurrentLogFile As String
            Get
                Return _currentLogFile
            End Get
        End Property

#End Region

#Region "Public Logging Methods"

        ''' <summary>
        ''' Logs a debug message. Used for detailed diagnostic information.
        ''' </summary>
        ''' <param name="source">The source class or component name.</param>
        ''' <param name="message">The message to log.</param>
        Public Sub Debug(source As String, message As String,
                        <CallerFilePath> Optional filePath As String = "",
                        <CallerLineNumber> Optional lineNumber As Integer = 0,
                        <CallerMemberName> Optional memberName As String = "")
            WriteLog(LogLevel.Debug, source, message, filePath, lineNumber, memberName)
        End Sub

        ''' <summary>
        ''' Logs an informational message. Used for successful operations and milestones.
        ''' </summary>
        ''' <param name="source">The source class or component name.</param>
        ''' <param name="message">The message to log.</param>
        Public Sub Info(source As String, message As String,
                       <CallerFilePath> Optional filePath As String = "",
                       <CallerLineNumber> Optional lineNumber As Integer = 0,
                       <CallerMemberName> Optional memberName As String = "")
            WriteLog(LogLevel.Info, source, message, filePath, lineNumber, memberName)
        End Sub

        ''' <summary>
        ''' Logs a warning message. Used for potential issues that don't stop execution.
        ''' </summary>
        ''' <param name="source">The source class or component name.</param>
        ''' <param name="message">The message to log.</param>
        Public Sub Warning(source As String, message As String,
                          <CallerFilePath> Optional filePath As String = "",
                          <CallerLineNumber> Optional lineNumber As Integer = 0,
                          <CallerMemberName> Optional memberName As String = "")
            WriteLog(LogLevel.Warning, source, message, filePath, lineNumber, memberName)
        End Sub

        ''' <summary>
        ''' Logs an error message. Used for failures that need attention.
        ''' </summary>
        ''' <param name="source">The source class or component name.</param>
        ''' <param name="message">The message to log.</param>
        Public Sub [Error](source As String, message As String,
                          <CallerFilePath> Optional filePath As String = "",
                          <CallerLineNumber> Optional lineNumber As Integer = 0,
                          <CallerMemberName> Optional memberName As String = "")
            WriteLog(LogLevel.Error, source, message, filePath, lineNumber, memberName)
        End Sub

        ''' <summary>
        ''' Logs an error message with exception details. Includes stack trace.
        ''' </summary>
        ''' <param name="source">The source class or component name.</param>
        ''' <param name="message">The message to log.</param>
        ''' <param name="ex">The exception to include in the log.</param>
        Public Sub [Error](source As String, message As String, ex As Exception,
                          <CallerFilePath> Optional filePath As String = "",
                          <CallerLineNumber> Optional lineNumber As Integer = 0,
                          <CallerMemberName> Optional memberName As String = "")
            Dim fullMessage As String = $"{message}{Environment.NewLine}Exception: {ex.GetType().Name}: {ex.Message}{Environment.NewLine}Stack Trace: {ex.StackTrace}"
            If ex.InnerException IsNot Nothing Then
                fullMessage &= $"{Environment.NewLine}Inner Exception: {ex.InnerException.GetType().Name}: {ex.InnerException.Message}"
            End If
            WriteLog(LogLevel.Error, source, fullMessage, filePath, lineNumber, memberName)
        End Sub

#End Region

#Region "Private Methods"

        ''' <summary>
        ''' Gets the default log directory path.
        ''' </summary>
        Private Function GetDefaultLogDirectory() As String
            Dim localAppData As String = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData)
            Return Path.Combine(localAppData, "EvAlis", "Logs")
        End Function

        ''' <summary>
        ''' Ensures the log directory exists, creating it if necessary.
        ''' </summary>
        Private Sub EnsureLogDirectoryExists()
            Try
                If Not Directory.Exists(_logDirectory) Then
                    Directory.CreateDirectory(_logDirectory)
                End If
            Catch ex As Exception
                ' If we can't create the log directory, fall back to temp directory
                _logDirectory = Path.GetTempPath()
                System.Diagnostics.Debug.WriteLine($"Logger: Could not create log directory, using temp: {ex.Message}")
            End Try
        End Sub

        ''' <summary>
        ''' Updates the current log file path for daily rotation.
        ''' </summary>
        Private Sub UpdateLogFile()
            Dim today As Date = Date.Today
            If _currentDate <> today OrElse String.IsNullOrEmpty(_currentLogFile) Then
                _currentDate = today
                _currentLogFile = Path.Combine(_logDirectory, $"evalis_{today:yyyy-MM-dd}.log")
            End If
        End Sub

        ''' <summary>
        ''' Writes a log entry to the file with caller information.
        ''' </summary>
        Private Sub WriteLog(level As LogLevel, source As String, message As String,
                            filePath As String, lineNumber As Integer, memberName As String)
            ' Check if this level should be logged
            If level < _minimumLevel Then
                Return
            End If

            Try
                SyncLock _writeLock
                    ' Check for date rollover
                    UpdateLogFile()

                    ' Format the log entry
                    Dim timestamp As String = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff")
                    Dim levelName As String = GetLevelName(level)

                    ' Extract just the filename from full path for cleaner logs
                    Dim fileName As String = If(String.IsNullOrEmpty(filePath), "", Path.GetFileName(filePath))

                    ' Build caller info string (only if available)
                    Dim callerInfo As String = ""
                    If Not String.IsNullOrEmpty(fileName) AndAlso lineNumber > 0 Then
                        callerInfo = $" {fileName}({lineNumber})"
                        If Not String.IsNullOrEmpty(memberName) Then
                            callerInfo &= $" in {memberName}"
                        End If
                    End If

                    Dim logEntry As String = $"[{timestamp}] [{levelName}] [{source}]{callerInfo} {message}{Environment.NewLine}"

                    ' Write to file (append mode)
                    File.AppendAllText(_currentLogFile, logEntry, Encoding.UTF8)

                    ' Also write to debug output for development
                    System.Diagnostics.Debug.Write(logEntry)
                End SyncLock
            Catch ex As Exception
                ' Don't let logging failures crash the application
                System.Diagnostics.Debug.WriteLine($"Logger: Failed to write log: {ex.Message}")
            End Try
        End Sub

        ''' <summary>
        ''' Gets the display name for a log level.
        ''' </summary>
        Private Function GetLevelName(level As LogLevel) As String
            Select Case level
                Case LogLevel.Debug
                    Return "DEBUG"
                Case LogLevel.Info
                    Return "INFO"
                Case LogLevel.Warning
                    Return "WARNING"
                Case LogLevel.Error
                    Return "ERROR"
                Case Else
                    Return "UNKNOWN"
            End Select
        End Function

#End Region

#Region "Utility Methods"

        ''' <summary>
        ''' Forces any buffered log entries to be written to disk.
        ''' Since we write immediately, this is a no-op but included for API completeness.
        ''' </summary>
        Public Sub Flush()
            ' Current implementation writes immediately, no buffering
            ' This method exists for API completeness and future buffering support
        End Sub

        ''' <summary>
        ''' Opens the log directory in Windows Explorer.
        ''' </summary>
        Public Sub OpenLogDirectory()
            Try
                If Directory.Exists(_logDirectory) Then
                    Process.Start("explorer.exe", _logDirectory)
                End If
            Catch ex As Exception
                System.Diagnostics.Debug.WriteLine($"Logger: Could not open log directory: {ex.Message}")
            End Try
        End Sub

#End Region

    End Class

End Namespace
