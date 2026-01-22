Namespace Models

    ''' <summary>
    ''' Represents the status of a login attempt.
    ''' </summary>
    Public Enum LoginStatus
        Success = 1
        Failed = 2
    End Enum

    ''' <summary>
    ''' Represents a login audit entry in the EvAlis system.
    ''' </summary>
    Public Class LoginAudit

        ''' <summary>
        ''' Unique identifier for the audit entry.
        ''' </summary>
        Public Property AuditId As Integer

        ''' <summary>
        ''' User ID (nullable for failed attempts with unknown users).
        ''' </summary>
        Public Property UserId As Integer?

        ''' <summary>
        ''' Username attempted for login.
        ''' </summary>
        Public Property Username As String

        ''' <summary>
        ''' Timestamp of the login attempt.
        ''' </summary>
        Public Property LoginTime As DateTime

        ''' <summary>
        ''' IP address of the client.
        ''' </summary>
        Public Property IpAddress As String

        ''' <summary>
        ''' Status of the login attempt.
        ''' </summary>
        Public Property Status As LoginStatus

        ''' <summary>
        ''' Reason for failure (if applicable).
        ''' </summary>
        Public Property FailureReason As String

        ''' <summary>
        ''' Default constructor.
        ''' </summary>
        Public Sub New()
            LoginTime = DateTime.Now
        End Sub

        ''' <summary>
        ''' Creates a successful login audit entry.
        ''' </summary>
        Public Shared Function CreateSuccess(userId As Integer, username As String, ipAddress As String) As LoginAudit
            Return New LoginAudit() With {
                .UserId = userId,
                .Username = username,
                .IpAddress = ipAddress,
                .Status = LoginStatus.Success,
                .FailureReason = Nothing
            }
        End Function

        ''' <summary>
        ''' Creates a failed login audit entry.
        ''' </summary>
        Public Shared Function CreateFailure(username As String, ipAddress As String, failureReason As String) As LoginAudit
            Return New LoginAudit() With {
                .UserId = Nothing,
                .Username = username,
                .IpAddress = ipAddress,
                .Status = LoginStatus.Failed,
                .FailureReason = failureReason
            }
        End Function

        ''' <summary>
        ''' Creates a failed login audit entry with known user.
        ''' </summary>
        Public Shared Function CreateFailure(userId As Integer, username As String, ipAddress As String, failureReason As String) As LoginAudit
            Return New LoginAudit() With {
                .UserId = userId,
                .Username = username,
                .IpAddress = ipAddress,
                .Status = LoginStatus.Failed,
                .FailureReason = failureReason
            }
        End Function

    End Class

End Namespace
