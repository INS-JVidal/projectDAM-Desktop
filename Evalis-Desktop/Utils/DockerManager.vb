Imports System.Diagnostics
Imports System.IO

Namespace Utils

    ''' <summary>
    ''' Docker execution mode - determines how to run Docker commands.
    ''' </summary>
    Public Enum DockerExecutionMode
        WindowsNative = 1    ' Docker Desktop on Windows
        WSLProxy = 2         ' Docker in WSL, accessed via wsl.exe
        NotAvailable = 0     ' Docker not detected
    End Enum

    ''' <summary>
    ''' Manages Docker container lifecycle for the EVALIS PostgreSQL database.
    ''' Provides methods to check Docker installation, start/stop containers, and monitor health.
    ''' </summary>
    Public Class DockerManager

        Private Const CONTAINER_NAME As String = "evalis-db"
        Private Const DOCKER_COMPOSE_PATH As String = "database/docker/docker-compose.yml"
        Private Const START_TIMEOUT_SECONDS As Integer = 120
        Private Const HEALTH_CHECK_INTERVAL As Integer = 2

        ' Docker execution mode detection
        Private Shared _executionMode As DockerExecutionMode = DockerExecutionMode.NotAvailable

        ''' <summary>
        ''' Checks if Docker Desktop/Engine is installed on the system.
        ''' Detects both Windows native Docker and Docker in WSL.
        ''' </summary>
        Public Shared Function IsDockerInstalled() As Boolean
            ' Try Windows native Docker Desktop
            Try
                Dim output As String = ExecuteCommand("docker --version")
                If Not String.IsNullOrWhiteSpace(output) AndAlso output.Contains("Docker version") Then
                    _executionMode = DockerExecutionMode.WindowsNative
                    Logger.Instance.Info("DockerManager", "Docker Desktop detected on Windows")
                    Return True
                End If
            Catch
                ' Windows native Docker not found, try WSL
            End Try

            ' Try WSL Docker
            Try
                Dim output As String = ExecuteCommand("wsl docker --version")
                If Not String.IsNullOrWhiteSpace(output) AndAlso output.Contains("Docker version") Then
                    _executionMode = DockerExecutionMode.WSLProxy
                    Logger.Instance.Info("DockerManager", "Docker detected in WSL")
                    Return True
                End If
            Catch
                ' WSL Docker not found either
            End Try

            _executionMode = DockerExecutionMode.NotAvailable
            Logger.Instance.Warning("DockerManager", "Docker not found on Windows or WSL")
            Return False
        End Function

        ''' <summary>
        ''' Checks if the Docker daemon is running and responsive.
        ''' </summary>
        Public Shared Function IsDockerRunning() As Boolean
            Try
                If _executionMode = DockerExecutionMode.WSLProxy Then
                    ExecuteCommand("wsl docker ps")
                Else
                    ExecuteCommand("docker ps")
                End If
                Return True
            Catch
                Return False
            End Try
        End Function

        ''' <summary>
        ''' Checks if the EVALIS PostgreSQL container is currently running.
        ''' </summary>
        Public Shared Function IsContainerRunning() As Boolean
            Try
                Dim output As String
                If _executionMode = DockerExecutionMode.WSLProxy Then
                    output = ExecuteCommand($"wsl docker ps --filter name={CONTAINER_NAME}")
                Else
                    output = ExecuteCommand($"docker ps --filter name={CONTAINER_NAME}")
                End If
                ' Check if output contains the container name (more than just header line)
                Return output.Split(New String() {Environment.NewLine}, StringSplitOptions.None).Length > 1 AndAlso output.Contains(CONTAINER_NAME)
            Catch
                Return False
            End Try
        End Function

        ''' <summary>
        ''' Starts the EVALIS PostgreSQL Docker container.
        ''' Returns True if successful, False otherwise.
        ''' </summary>
        Public Shared Function StartContainer() As Boolean
            Try
                Dim composePath As String = GetDockerComposePath()
                Dim workingDirectory As String = Path.GetDirectoryName(composePath)

                ' Use docker-compose to start the container
                If _executionMode = DockerExecutionMode.WSLProxy Then
                    ' Convert Windows path to WSL path (e.g., C:\path -> /mnt/c/path)
                    Dim wslPath As String = workingDirectory.Replace("C:\", "/mnt/c/").Replace("\", "/")
                    Dim command As String = $"bash -c ""cd '{wslPath}' && docker-compose up -d"""
                    ExecuteCommand($"wsl {command}")
                    Logger.Instance.Info("DockerManager", "Container started via WSL")
                Else
                    ExecuteCommand("docker-compose up -d", workingDirectory)
                    Logger.Instance.Info("DockerManager", "Container started via Docker Desktop")
                End If

                Return True
            Catch ex As Exception
                Logger.Instance.Error("DockerManager", "Failed to start container", ex)
                Return False
            End Try
        End Function

        ''' <summary>
        ''' Stops the EVALIS PostgreSQL Docker container gracefully.
        ''' Returns True if successful, False otherwise.
        ''' </summary>
        Public Shared Function StopContainer() As Boolean
            Try
                Dim composePath As String = GetDockerComposePath()
                Dim workingDirectory As String = Path.GetDirectoryName(composePath)

                ' Use docker-compose to stop the container
                If _executionMode = DockerExecutionMode.WSLProxy Then
                    ' Convert Windows path to WSL path
                    Dim wslPath As String = workingDirectory.Replace("C:\", "/mnt/c/").Replace("\", "/")
                    Dim command As String = $"bash -c ""cd '{wslPath}' && docker-compose down"""
                    ExecuteCommand($"wsl {command}")
                    Logger.Instance.Info("DockerManager", "Container stopped via WSL")
                Else
                    ExecuteCommand("docker-compose down", workingDirectory)
                    Logger.Instance.Info("DockerManager", "Container stopped via Docker Desktop")
                End If

                Return True
            Catch ex As Exception
                Logger.Instance.Error("DockerManager", "Failed to stop container", ex)
                Return False
            End Try
        End Function

        ''' <summary>
        ''' Waits for the PostgreSQL database to be ready for connections.
        ''' Returns True if database becomes ready within timeout, False on timeout.
        ''' </summary>
        Public Shared Function WaitForDatabaseReady(Optional timeoutSeconds As Integer = START_TIMEOUT_SECONDS) As Boolean
            Try
                Dim startTime As DateTime = DateTime.Now
                Dim timeout As TimeSpan = TimeSpan.FromSeconds(timeoutSeconds)

                While DateTime.Now - startTime < timeout
                    ' Test if database is accepting connections
                    If DatabaseManager.TestConnection() Then
                        Return True
                    End If

                    ' Wait before next check
                    System.Threading.Thread.Sleep(HEALTH_CHECK_INTERVAL * 1000)
                End While

                Return False
            Catch ex As Exception
                Logger.Instance.Error("DockerManager", "Error waiting for database to be ready", ex)
                Return False
            End Try
        End Function

        ''' <summary>
        ''' Gets the current status of the EVALIS PostgreSQL container.
        ''' Returns: "Running", "Stopped", "Not Found", or "Docker Not Running"
        ''' </summary>
        Public Shared Function GetContainerStatus() As String
            Try
                ' Check if Docker is running
                If Not IsDockerRunning() Then
                    Return "Docker Not Running"
                End If

                ' Check container status
                Dim output As String
                If _executionMode = DockerExecutionMode.WSLProxy Then
                    output = ExecuteCommand($"wsl docker ps -a --filter name={CONTAINER_NAME}")
                Else
                    output = ExecuteCommand($"docker ps -a --filter name={CONTAINER_NAME}")
                End If

                If String.IsNullOrWhiteSpace(output) OrElse output.Split(New String() {Environment.NewLine}, StringSplitOptions.None).Length <= 1 Then
                    Return "Not Found"
                End If

                ' Check if running or stopped
                If IsContainerRunning() Then
                    Return "Running"
                Else
                    Return "Stopped"
                End If
            Catch ex As Exception
                Logger.Instance.Error("DockerManager", "Error getting container status", ex)
                Return "Unknown"
            End Try
        End Function

        ''' <summary>
        ''' Retrieves the last N lines of container logs for troubleshooting.
        ''' </summary>
        Public Shared Function GetContainerLogs(Optional lines As Integer = 50) As String
            Try
                If _executionMode = DockerExecutionMode.WSLProxy Then
                    Return ExecuteCommand($"wsl docker logs {CONTAINER_NAME} --tail {lines}")
                Else
                    Return ExecuteCommand($"docker logs {CONTAINER_NAME} --tail {lines}")
                End If
            Catch ex As Exception
                Return $"Error retrieving logs: {ex.Message}"
            End Try
        End Function

        ''' <summary>
        ''' Main entry point for application startup.
        ''' Ensures Docker is installed, running, and database is ready.
        ''' Returns True if successful, False if unable to start database.
        ''' </summary>
        Public Shared Function EnsureDatabaseRunning() As Boolean
            Try
                ' Step 1: Check Docker installed
                If Not IsDockerInstalled() Then
                    Logger.Instance.Debug("DockerManager", "Docker is not installed")
                    Return False
                End If

                ' Step 2: Check Docker running
                If Not IsDockerRunning() Then
                    Logger.Instance.Info("DockerManager", "Docker daemon not running, attempting to start...")
                    ' On Windows, Docker Desktop needs to be launched
                    If Not TryStartDockerDesktop() Then
                        Logger.Instance.Warning("DockerManager", "Could not start Docker Desktop")
                        Return False
                    End If

                    ' Wait for Docker to be ready
                    If Not WaitForDockerStartup(30) Then
                        Logger.Instance.Error("DockerManager", "Docker failed to start within timeout (30s)")
                        Return False
                    End If
                End If

                ' Step 3: Check container running
                If Not IsContainerRunning() Then
                    Logger.Instance.Info("DockerManager", "Container not running, starting...")
                    If Not StartContainer() Then
                        Logger.Instance.Error("DockerManager", "Failed to start container")
                        Return False
                    End If
                End If

                ' Step 4: Wait for database ready
                Logger.Instance.Debug("DockerManager", "Waiting for database to be ready...")
                Return WaitForDatabaseReady(START_TIMEOUT_SECONDS)

            Catch ex As Exception
                Logger.Instance.Error("DockerManager", "Unexpected error in EnsureDatabaseRunning", ex)
                Return False
            End Try
        End Function

        ''' <summary>
        ''' Attempts to start Docker Desktop on Windows.
        ''' Skips if using WSL Docker.
        ''' </summary>
        Private Shared Function TryStartDockerDesktop() As Boolean
            ' WSL Docker doesn't need Docker Desktop
            If _executionMode = DockerExecutionMode.WSLProxy Then
                Logger.Instance.Debug("DockerManager", "Using WSL Docker, skipping Docker Desktop start")
                Return True
            End If

            Try
                ' Common Docker Desktop installation paths on Windows
                Dim dockerPaths As String() = {
                    "C:\Program Files\Docker\Docker\Docker Desktop.exe",
                    "C:\Program Files (x86)\Docker\Docker\Docker Desktop.exe"
                }

                For Each path In dockerPaths
                    If File.Exists(path) Then
                        Dim psi As New ProcessStartInfo(path)
                        psi.UseShellExecute = True
                        Process.Start(psi)
                        Logger.Instance.Info("DockerManager", "Started Docker Desktop")
                        Return True
                    End If
                Next

                Logger.Instance.Warning("DockerManager", "Docker Desktop executable not found")
                Return False
            Catch ex As Exception
                Logger.Instance.Error("DockerManager", "Error starting Docker Desktop", ex)
                Return False
            End Try
        End Function

        ''' <summary>
        ''' Waits for Docker daemon to be ready.
        ''' </summary>
        Private Shared Function WaitForDockerStartup(timeoutSeconds As Integer) As Boolean
            Try
                Dim startTime As DateTime = DateTime.Now
                Dim timeout As TimeSpan = TimeSpan.FromSeconds(timeoutSeconds)

                While DateTime.Now - startTime < timeout
                    If IsDockerRunning() Then
                        Return True
                    End If
                    System.Threading.Thread.Sleep(2000) ' Check every 2 seconds
                End While

                Return False
            Catch ex As Exception
                Logger.Instance.Error("DockerManager", "Error waiting for Docker startup", ex)
                Return False
            End Try
        End Function

        ''' <summary>
        ''' Executes a command (typically Docker or docker-compose commands).
        ''' Throws an exception if the command fails.
        ''' </summary>
        Private Shared Function ExecuteCommand(command As String, Optional workingDirectory As String = Nothing) As String
            Try
                ' Parse command into executable and arguments
                Dim parts As String() = command.Split(" "c, 2)
                Dim executable As String = parts(0)
                Dim arguments As String = If(parts.Length > 1, parts(1), "")

                Dim psi As New ProcessStartInfo()
                psi.FileName = executable
                psi.Arguments = arguments
                psi.UseShellExecute = False
                psi.RedirectStandardOutput = True
                psi.RedirectStandardError = True
                psi.CreateNoWindow = True

                ' Set working directory if provided
                If Not String.IsNullOrEmpty(workingDirectory) Then
                    psi.WorkingDirectory = workingDirectory
                End If

                Using process As Process = Process.Start(psi)
                    Dim output As String = process.StandardOutput.ReadToEnd()
                    Dim errorOutput As String = process.StandardError.ReadToEnd()

                    process.WaitForExit()

                    If process.ExitCode <> 0 Then
                        Throw New Exception($"Command failed with exit code {process.ExitCode}: {errorOutput}")
                    End If

                    Return output
                End Using

            Catch ex As Exception
                Throw New Exception($"Error executing command '{command}': {ex.Message}", ex)
            End Try
        End Function

        ''' <summary>
        ''' Gets the full path to the docker-compose.yml file.
        ''' </summary>
        Private Shared Function GetDockerComposePath() As String
            Dim basePath As String = AppDomain.CurrentDomain.BaseDirectory
            ' Navigate up to the project root, then to docker-compose.yml
            Dim projectRoot As String = Directory.GetParent(basePath).FullName
            Return Path.Combine(projectRoot, DOCKER_COMPOSE_PATH)
        End Function

        ''' <summary>
        ''' Gets the currently detected Docker execution mode.
        ''' </summary>
        ''' <returns>The Docker execution mode (WindowsNative, WSLProxy, or NotAvailable)</returns>
        Public Shared Function GetExecutionMode() As DockerExecutionMode
            Return _executionMode
        End Function

    End Class

End Namespace
