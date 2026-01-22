Imports Npgsql
Imports Evalis_Desktop.Models
Imports Evalis_Desktop.Utils

Namespace Repositories

    ''' <summary>
    ''' Repository for login audit data access operations.
    ''' </summary>
    Public Class AuditRepository

        ''' <summary>
        ''' Logs a login attempt to the database.
        ''' </summary>
        ''' <param name="audit">The login audit entry to log.</param>
        ''' <returns>True if successful, false otherwise.</returns>
        Public Function LogLoginAttempt(audit As LoginAudit) As Boolean
            If audit Is Nothing Then
                Return False
            End If

            Try
                Using conn As NpgsqlConnection = DatabaseManager.GetConnection()
                    conn.Open()

                    Const sql As String = "INSERT INTO login_audit (user_id, username, login_time, ip_address, status, failure_reason) " &
                                           "VALUES (@userId, @username, @loginTime, @ipAddress, @status, @failureReason)"

                    Using cmd As New NpgsqlCommand(sql, conn)
                        If audit.UserId.HasValue Then
                            cmd.Parameters.AddWithValue("@userId", audit.UserId.Value)
                        Else
                            cmd.Parameters.AddWithValue("@userId", DBNull.Value)
                        End If

                        cmd.Parameters.AddWithValue("@username", audit.Username)
                        cmd.Parameters.AddWithValue("@loginTime", audit.LoginTime)
                        cmd.Parameters.AddWithValue("@ipAddress", If(audit.IpAddress, DBNull.Value))
                        cmd.Parameters.AddWithValue("@status", GetStatusString(audit.Status))
                        cmd.Parameters.AddWithValue("@failureReason", If(audit.FailureReason, DBNull.Value))

                        cmd.ExecuteNonQuery()
                        Return True
                    End Using
                End Using
            Catch ex As Exception
                ' Log error but don't throw - audit logging shouldn't break login flow
                Logger.Instance.Error("AuditRepository", "Failed to log audit entry", ex)
                Return False
            End Try
        End Function

        ''' <summary>
        ''' Converts LoginStatus enum to database string.
        ''' </summary>
        Private Function GetStatusString(status As LoginStatus) As String
            Select Case status
                Case LoginStatus.Success
                    Return "SUCCESS"
                Case LoginStatus.Failed
                    Return "FAILED"
                Case Else
                    Return "UNKNOWN"
            End Select
        End Function

    End Class

End Namespace
