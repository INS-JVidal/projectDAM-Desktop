Imports Npgsql
Imports Evalis_Desktop.Models
Imports Evalis_Desktop.Utils

Namespace Repositories

    ''' <summary>
    ''' Repository for session data access operations.
    ''' </summary>
    Public Class SessionRepository

        ''' <summary>
        ''' Creates a new session in the database.
        ''' </summary>
        ''' <param name="session">The session to create.</param>
        ''' <returns>True if successful, false otherwise.</returns>
        Public Function CreateSession(session As UserSession) As Boolean
            If session Is Nothing Then
                Return False
            End If

            Try
                Using conn As NpgsqlConnection = DatabaseManager.GetConnection()
                    conn.Open()

                    Const sql As String = "INSERT INTO sessions (session_id, user_id, login_time, last_activity, ip_address, is_active) " &
                                           "VALUES (@sessionId, @userId, @loginTime, @lastActivity, @ipAddress, @isActive)"

                    Using cmd As New NpgsqlCommand(sql, conn)
                        cmd.Parameters.AddWithValue("@sessionId", session.SessionId)
                        cmd.Parameters.AddWithValue("@userId", session.UserId)
                        cmd.Parameters.AddWithValue("@loginTime", session.LoginTime)
                        cmd.Parameters.AddWithValue("@lastActivity", session.LastActivity)
                        cmd.Parameters.AddWithValue("@ipAddress", If(session.IpAddress, DBNull.Value))
                        cmd.Parameters.AddWithValue("@isActive", session.IsActive)

                        cmd.ExecuteNonQuery()
                        Return True
                    End Using
                End Using
            Catch ex As Exception
                Logger.Instance.Error("SessionRepository", "Failed to create session", ex)
                Return False
            End Try
        End Function

        ''' <summary>
        ''' Updates the last activity timestamp for a session.
        ''' </summary>
        ''' <param name="sessionId">The session ID to update.</param>
        ''' <returns>True if successful, false otherwise.</returns>
        Public Function UpdateLastActivity(sessionId As Guid) As Boolean
            Try
                Using conn As NpgsqlConnection = DatabaseManager.GetConnection()
                    conn.Open()

                    Const sql As String = "UPDATE sessions SET last_activity = @lastActivity WHERE session_id = @sessionId AND is_active = true"

                    Using cmd As New NpgsqlCommand(sql, conn)
                        cmd.Parameters.AddWithValue("@sessionId", sessionId)
                        cmd.Parameters.AddWithValue("@lastActivity", DateTime.Now)

                        Dim rowsAffected As Integer = cmd.ExecuteNonQuery()
                        Return rowsAffected > 0
                    End Using
                End Using
            Catch ex As Exception
                Logger.Instance.Error("SessionRepository", "Failed to update session activity", ex)
                Return False
            End Try
        End Function

        ''' <summary>
        ''' Deactivates a session.
        ''' </summary>
        ''' <param name="sessionId">The session ID to deactivate.</param>
        ''' <returns>True if successful, false otherwise.</returns>
        Public Function DeactivateSession(sessionId As Guid) As Boolean
            Try
                Using conn As NpgsqlConnection = DatabaseManager.GetConnection()
                    conn.Open()

                    Const sql As String = "UPDATE sessions SET is_active = false WHERE session_id = @sessionId"

                    Using cmd As New NpgsqlCommand(sql, conn)
                        cmd.Parameters.AddWithValue("@sessionId", sessionId)

                        Dim rowsAffected As Integer = cmd.ExecuteNonQuery()
                        Return rowsAffected > 0
                    End Using
                End Using
            Catch ex As Exception
                Logger.Instance.Error("SessionRepository", "Failed to deactivate session", ex)
                Return False
            End Try
        End Function

        ''' <summary>
        ''' Deactivates all sessions for a user.
        ''' </summary>
        ''' <param name="userId">The user ID whose sessions to deactivate.</param>
        ''' <returns>True if successful, false otherwise.</returns>
        Public Function DeactivateUserSessions(userId As Integer) As Boolean
            Try
                Using conn As NpgsqlConnection = DatabaseManager.GetConnection()
                    conn.Open()

                    Const sql As String = "UPDATE sessions SET is_active = false WHERE user_id = @userId AND is_active = true"

                    Using cmd As New NpgsqlCommand(sql, conn)
                        cmd.Parameters.AddWithValue("@userId", userId)

                        cmd.ExecuteNonQuery()
                        Return True
                    End Using
                End Using
            Catch ex As Exception
                Logger.Instance.Error("SessionRepository", "Failed to deactivate user sessions", ex)
                Return False
            End Try
        End Function

    End Class

End Namespace
