Imports System.Xml
Imports Npgsql

Namespace Utils

    ''' <summary>
    ''' Manages database connections for the EvAlis application.
    ''' Reads connection settings from Config/database.config.
    ''' </summary>
    Public Class DatabaseManager

        Private Shared _connectionString As String = Nothing
        Private Shared ReadOnly _lockObject As New Object()

        ''' <summary>
        ''' Gets the connection string from the configuration file.
        ''' </summary>
        Public Shared ReadOnly Property ConnectionString As String
            Get
                If _connectionString Is Nothing Then
                    SyncLock _lockObject
                        If _connectionString Is Nothing Then
                            _connectionString = LoadConnectionString()
                        End If
                    End SyncLock
                End If
                Return _connectionString
            End Get
        End Property

        ''' <summary>
        ''' Loads the connection string from the configuration file.
        ''' </summary>
        Private Shared Function LoadConnectionString() As String
            Try
                Dim configPath As String = GetConfigPath()
                Logger.Instance.Debug("DatabaseManager", $"Loading configuration from: {configPath}")

                If Not IO.File.Exists(configPath) Then
                    Logger.Instance.Error("DatabaseManager", $"Configuration file not found: {configPath}")
                    Throw New IO.FileNotFoundException($"Database configuration file not found: {configPath}")
                End If

                Dim doc As New XmlDocument()
                doc.Load(configPath)

                ' Get the active connection name
                Dim activeConnectionNode As XmlNode = doc.SelectSingleNode("//appSettings/add[@key='ActiveConnection']")
                If activeConnectionNode Is Nothing Then
                    Logger.Instance.Error("DatabaseManager", "ActiveConnection setting not found in configuration")
                    Throw New Exception("ActiveConnection setting not found in configuration.")
                End If
                Dim activeConnectionName As String = activeConnectionNode.Attributes("value").Value

                ' Get the connection string
                Dim connectionNode As XmlNode = doc.SelectSingleNode($"//connectionStrings/add[@name='{activeConnectionName}']")
                If connectionNode Is Nothing Then
                    Logger.Instance.Error("DatabaseManager", $"Connection string '{activeConnectionName}' not found in configuration")
                    Throw New Exception($"Connection string '{activeConnectionName}' not found in configuration.")
                End If

                Logger.Instance.Info("DatabaseManager", $"Database configuration loaded successfully (Connection: {activeConnectionName})")
                Return connectionNode.Attributes("connectionString").Value

            Catch ex As IO.FileNotFoundException
                Throw
            Catch ex As Exception
                Logger.Instance.Error("DatabaseManager", "Error loading database configuration", ex)
                Throw New Exception($"Error loading database configuration: {ex.Message}", ex)
            End Try
        End Function

        ''' <summary>
        ''' Gets the path to the configuration file.
        ''' </summary>
        Private Shared Function GetConfigPath() As String
            Dim basePath As String = AppDomain.CurrentDomain.BaseDirectory
            Return IO.Path.Combine(basePath, "Config", "database.config")
        End Function

        ''' <summary>
        ''' Creates and returns a new database connection.
        ''' The caller is responsible for disposing the connection.
        ''' </summary>
        Public Shared Function GetConnection() As NpgsqlConnection
            Return New NpgsqlConnection(ConnectionString)
        End Function

        ''' <summary>
        ''' Tests the database connection.
        ''' </summary>
        Public Shared Function TestConnection() As Boolean
            Try
                Logger.Instance.Debug("DatabaseManager", "Testing database connection...")
                Using conn As NpgsqlConnection = GetConnection()
                    conn.Open()
                    Logger.Instance.Info("DatabaseManager", "Database connection test successful")
                    Return True
                End Using
            Catch ex As Exception
                Logger.Instance.Error("DatabaseManager", "Database connection test failed", ex)
                Return False
            End Try
        End Function

        ''' <summary>
        ''' Reloads the connection string from the configuration file.
        ''' </summary>
        Public Shared Sub ReloadConfiguration()
            SyncLock _lockObject
                _connectionString = Nothing
            End SyncLock
        End Sub

    End Class

End Namespace
