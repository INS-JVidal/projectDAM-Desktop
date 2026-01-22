Imports System.Net
Imports System.Net.Sockets
Imports Evalis_Desktop.Models
Imports Evalis_Desktop.Repositories
Imports Evalis_Desktop.Utils

Namespace Services

    ''' <summary>
    ''' Provides authentication services for the EvAlis application.
    ''' </summary>
    Public Class AuthenticationService

        Private Shared _currentUser As User
        Private Shared _currentSession As UserSession
        Private Shared ReadOnly _userRepository As New UserRepository()
        Private Shared ReadOnly _auditRepository As New AuditRepository()
        Private Shared ReadOnly _sessionRepository As New SessionRepository()

        ''' <summary>
        ''' Gets the currently authenticated user.
        ''' </summary>
        Public Shared ReadOnly Property CurrentUser As User
            Get
                Return _currentUser
            End Get
        End Property

        ''' <summary>
        ''' Gets the current session.
        ''' </summary>
        Public Shared ReadOnly Property CurrentSession As UserSession
            Get
                Return _currentSession
            End Get
        End Property

        ''' <summary>
        ''' Indicates whether a user is currently authenticated.
        ''' </summary>
        Public Shared ReadOnly Property IsAuthenticated As Boolean
            Get
                Return _currentUser IsNot Nothing AndAlso
                       _currentSession IsNot Nothing AndAlso
                       Not _currentSession.IsExpired
            End Get
        End Property

        ''' <summary>
        ''' Authenticates a user with the provided credentials.
        ''' </summary>
        ''' <param name="username">The username.</param>
        ''' <param name="password">The plain text password.</param>
        ''' <returns>An authentication result with success status and error message if applicable.</returns>
        Public Shared Function Authenticate(username As String, password As String) As AuthenticationResult
            Dim ipAddress As String = GetLocalIpAddress()

            Logger.Instance.Debug("AuthenticationService", $"Login attempt for user: {username} from IP: {ipAddress}")

            ' Validate input
            If String.IsNullOrWhiteSpace(username) Then
                Logger.Instance.Warning("AuthenticationService", "Login attempt with empty username")
                Return AuthenticationResult.Failure("Username is required.")
            End If

            If String.IsNullOrWhiteSpace(password) Then
                Logger.Instance.Warning("AuthenticationService", $"Login attempt with empty password for user: {username}")
                Return AuthenticationResult.Failure("Password is required.")
            End If

            Try
                ' Get user from database
                Dim user As User = _userRepository.GetByUsername(username)

                ' User not found
                If user Is Nothing Then
                    Logger.Instance.Warning("AuthenticationService", $"Failed login for '{username}': User not found")
                    _auditRepository.LogLoginAttempt(LoginAudit.CreateFailure(username, ipAddress, "User not found"))
                    Return AuthenticationResult.Failure("Invalid username or password.")
                End If

                ' User is inactive
                If Not user.IsActive Then
                    Logger.Instance.Warning("AuthenticationService", $"Failed login for '{username}': Account inactive")
                    _auditRepository.LogLoginAttempt(LoginAudit.CreateFailure(user.UserId, username, ipAddress, "Account inactive"))
                    Return AuthenticationResult.Failure("Your account has been deactivated. Contact your administrator.")
                End If

                ' Verify password
                If Not PasswordHasher.VerifyPassword(password, user.PasswordHash) Then
                    Logger.Instance.Warning("AuthenticationService", $"Failed login for '{username}': Invalid password")
                    _auditRepository.LogLoginAttempt(LoginAudit.CreateFailure(user.UserId, username, ipAddress, "Invalid password"))
                    Return AuthenticationResult.Failure("Invalid username or password.")
                End If

                ' Deactivate any existing sessions for this user
                _sessionRepository.DeactivateUserSessions(user.UserId)

                ' Create new session
                Dim session As New UserSession(user.UserId, ipAddress)
                _sessionRepository.CreateSession(session)

                ' Log successful login
                _auditRepository.LogLoginAttempt(LoginAudit.CreateSuccess(user.UserId, username, ipAddress))
                Logger.Instance.Info("AuthenticationService", $"User '{username}' authenticated successfully (Role: {user.Role})")

                ' Set current user and session
                _currentUser = user
                _currentSession = session

                Return AuthenticationResult.Success()

            Catch ex As Exception
                Logger.Instance.Error("AuthenticationService", $"Authentication error for user '{username}'", ex)
                _auditRepository.LogLoginAttempt(LoginAudit.CreateFailure(username, ipAddress, $"System error: {ex.Message}"))
                Return AuthenticationResult.Failure("An error occurred during login. Please try again.")
            End Try
        End Function

        ''' <summary>
        ''' Logs out the current user.
        ''' </summary>
        Public Shared Sub Logout()
            Dim username As String = If(_currentUser?.Username, "unknown")
            Logger.Instance.Info("AuthenticationService", $"User '{username}' logging out")

            If _currentSession IsNot Nothing Then
                _sessionRepository.DeactivateSession(_currentSession.SessionId)
            End If

            _currentUser = Nothing
            _currentSession = Nothing

            Logger.Instance.Debug("AuthenticationService", "Session cleared")
        End Sub

        ''' <summary>
        ''' Checks if the current session has timed out.
        ''' </summary>
        ''' <returns>True if the session has expired, false otherwise.</returns>
        Public Shared Function CheckSessionTimeout() As Boolean
            If _currentSession Is Nothing Then
                Return True
            End If
            Return _currentSession.IsExpired
        End Function

        ''' <summary>
        ''' Refreshes the current session by updating the last activity timestamp.
        ''' </summary>
        Public Shared Sub RefreshSession()
            If _currentSession IsNot Nothing AndAlso Not _currentSession.IsExpired Then
                _currentSession.RefreshActivity()
                _sessionRepository.UpdateLastActivity(_currentSession.SessionId)
            End If
        End Sub

        ''' <summary>
        ''' Gets the local IP address of the machine.
        ''' </summary>
        Private Shared Function GetLocalIpAddress() As String
            Try
                Dim host As IPHostEntry = Dns.GetHostEntry(Dns.GetHostName())
                For Each ip As IPAddress In host.AddressList
                    If ip.AddressFamily = AddressFamily.InterNetwork Then
                        Return ip.ToString()
                    End If
                Next
            Catch
            End Try
            Return "127.0.0.1"
        End Function

    End Class

    ''' <summary>
    ''' Represents the result of an authentication attempt.
    ''' </summary>
    Public Class AuthenticationResult

        ''' <summary>
        ''' Indicates whether the authentication was successful.
        ''' </summary>
        Public Property IsSuccess As Boolean

        ''' <summary>
        ''' Error message if authentication failed.
        ''' </summary>
        Public Property ErrorMessage As String

        Private Sub New()
        End Sub

        ''' <summary>
        ''' Creates a successful authentication result.
        ''' </summary>
        Public Shared Function Success() As AuthenticationResult
            Return New AuthenticationResult() With {
                .IsSuccess = True,
                .ErrorMessage = Nothing
            }
        End Function

        ''' <summary>
        ''' Creates a failed authentication result.
        ''' </summary>
        Public Shared Function Failure(errorMessage As String) As AuthenticationResult
            Return New AuthenticationResult() With {
                .IsSuccess = False,
                .ErrorMessage = errorMessage
            }
        End Function

    End Class

End Namespace
