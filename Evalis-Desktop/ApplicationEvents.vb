Imports Microsoft.VisualBasic.ApplicationServices
Imports Evalis_Desktop.Forms
Imports Evalis_Desktop.Utils

Namespace My
    ' The following events are available for MyApplication:
    ' Startup: Raised when the application starts, before the startup form is created.
    ' Shutdown: Raised after all application forms are closed.  This event is not raised if the application terminates abnormally.
    ' UnhandledException: Raised if the application encounters an unhandled exception.
    ' StartupNextInstance: Raised when launching a single-instance application and the application is already active.
    ' NetworkAvailabilityChanged: Raised when the network connection is connected or disconnected.

    Partial Friend Class MyApplication

        ''' <summary>
        ''' Ensures Docker and database are running before showing the LoginForm.
        ''' If database cannot be started, the application exits.
        ''' If login fails or is cancelled, the application exits.
        ''' </summary>
        Private Sub MyApplication_Startup(sender As Object, e As StartupEventArgs) Handles Me.Startup
            Logger.Instance.Info("Application", "EvAlis starting...")
            Logger.Instance.Debug("Application", $"Log directory: {Logger.Instance.LogDirectory}")

            ' Ensure Docker and database are ready before proceeding
            If Not EnsureDatabaseStartup() Then
                Logger.Instance.Error("Application", "Database startup failed - application exiting")
                e.Cancel = True
                Return
            End If

            Logger.Instance.Info("Application", "Database ready")

            ' Show login form after database is ready
            Dim loginForm As New LoginForm()
            If loginForm.ShowDialog() <> DialogResult.OK Then
                Logger.Instance.Info("Application", "Login cancelled or failed - application exiting")
                e.Cancel = True
                Return
            End If

            Logger.Instance.Info("Application", "EvAlis started successfully")
        End Sub

        ''' <summary>
        ''' Ensures Docker container and database are running.
        ''' Shows appropriate error messages if unable to start.
        ''' Returns True if successful, False otherwise.
        ''' </summary>
        Private Function EnsureDatabaseStartup() As Boolean
            Try
                ' Quick check: Is database already accessible?
                Logger.Instance.Debug("Application", "Testing database connection...")
                If DatabaseManager.TestConnection() Then
                    Logger.Instance.Info("Application", "Database already available, skipping Docker checks")
                    Return True
                End If

                Logger.Instance.Debug("Application", "Database not accessible, checking Docker...")

                ' Show a splash screen or status message
                Dim statusForm As New SplashScreenForm("Starting database...", "Please wait while the database initializes.")
                statusForm.Show()
                Application.DoEvents()

                ' Attempt to ensure database is running
                If Not DockerManager.EnsureDatabaseRunning() Then
                    statusForm.Close()

                    ' Check which step failed for better error messaging
                    If Not DockerManager.IsDockerInstalled() Then
                        Logger.Instance.Error("Application", "Docker is not installed")
                        MessageBox.Show(
                            "Docker is required but not found." & vbCrLf & vbCrLf &
                            "Install options:" & vbCrLf &
                            "• Docker Desktop: https://docker.com/products/docker-desktop" & vbCrLf &
                            "• WSL: wsl sudo apt install docker.io docker-compose" & vbCrLf & vbCrLf &
                            "After installation, restart the application.",
                            "Docker Not Installed",
                            MessageBoxButtons.OK,
                            MessageBoxIcon.Error
                        )
                    ElseIf Not DockerManager.IsDockerRunning() Then
                        Dim executionMode = DockerManager.GetExecutionMode()
                        Dim isWSL As Boolean = (executionMode = DockerExecutionMode.WSLProxy)

                        Logger.Instance.Error("Application", $"Docker is not running (Mode: {executionMode})")
                        MessageBox.Show(
                            If(isWSL,
                               "Docker in WSL is not running." & vbCrLf & vbCrLf &
                               "Start it with: wsl sudo service docker start",
                               "Docker Desktop is not running." & vbCrLf & vbCrLf &
                               "Please start Docker Desktop and try again."),
                            "Docker Not Running",
                            MessageBoxButtons.OK,
                            MessageBoxIcon.Error
                        )
                    Else
                        ' Database startup failed
                        Dim containerStatus As String = DockerManager.GetContainerStatus()
                        Dim logs As String = DockerManager.GetContainerLogs(20)
                        Logger.Instance.Error("Application", $"Database container startup failed. Status: {containerStatus}")
                        MessageBox.Show(
                            "Unable to start the database. Please check your Docker installation." & vbCrLf & vbCrLf &
                            "Container Status: " & containerStatus & vbCrLf & vbCrLf &
                            "Recent logs:" & vbCrLf & logs,
                            "Database Startup Failed",
                            MessageBoxButtons.OK,
                            MessageBoxIcon.Error
                        )
                    End If

                    Return False
                End If

                statusForm.Close()
                Logger.Instance.Debug("Application", "Docker and database startup completed successfully")
                Return True

            Catch ex As Exception
                Logger.Instance.Error("Application", "Unexpected error during database startup", ex)
                MessageBox.Show(
                    "An unexpected error occurred while starting the database:" & vbCrLf & vbCrLf &
                    ex.Message,
                    "Startup Error",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error
                )
                Return False
            End Try
        End Function

    End Class
End Namespace
