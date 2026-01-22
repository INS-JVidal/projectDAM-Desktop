Namespace Models

    ''' <summary>
    ''' Represents a user session in the EvAlis system.
    ''' </summary>
    Public Class UserSession

        ''' <summary>
        ''' Session timeout in minutes.
        ''' </summary>
        Private Const SESSION_TIMEOUT_MINUTES As Integer = 30

        ''' <summary>
        ''' Unique session identifier.
        ''' </summary>
        Public Property SessionId As Guid

        ''' <summary>
        ''' User ID associated with this session.
        ''' </summary>
        Public Property UserId As Integer

        ''' <summary>
        ''' Timestamp when the session was created.
        ''' </summary>
        Public Property LoginTime As DateTime

        ''' <summary>
        ''' Timestamp of last user activity.
        ''' </summary>
        Public Property LastActivity As DateTime

        ''' <summary>
        ''' IP address of the client.
        ''' </summary>
        Public Property IpAddress As String

        ''' <summary>
        ''' Indicates if the session is active.
        ''' </summary>
        Public Property IsActive As Boolean

        ''' <summary>
        ''' Default constructor.
        ''' </summary>
        Public Sub New()
            SessionId = Guid.NewGuid()
            LoginTime = DateTime.Now
            LastActivity = DateTime.Now
            IsActive = True
        End Sub

        ''' <summary>
        ''' Constructor with user ID and IP address.
        ''' </summary>
        Public Sub New(userId As Integer, ipAddress As String)
            Me.New()
            Me.UserId = userId
            Me.IpAddress = ipAddress
        End Sub

        ''' <summary>
        ''' Checks if the session has expired due to inactivity.
        ''' </summary>
        Public ReadOnly Property IsExpired As Boolean
            Get
                If Not IsActive Then
                    Return True
                End If
                Return DateTime.Now.Subtract(LastActivity).TotalMinutes > SESSION_TIMEOUT_MINUTES
            End Get
        End Property

        ''' <summary>
        ''' Gets the remaining session time in minutes.
        ''' </summary>
        Public ReadOnly Property RemainingMinutes As Double
            Get
                Dim elapsed As Double = DateTime.Now.Subtract(LastActivity).TotalMinutes
                Return Math.Max(0, SESSION_TIMEOUT_MINUTES - elapsed)
            End Get
        End Property

        ''' <summary>
        ''' Refreshes the session by updating the last activity timestamp.
        ''' </summary>
        Public Sub RefreshActivity()
            LastActivity = DateTime.Now
        End Sub

    End Class

End Namespace
