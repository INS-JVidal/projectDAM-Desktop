Imports Npgsql
Imports Evalis_Desktop.Models
Imports Evalis_Desktop.Utils

Namespace Repositories

    ''' <summary>
    ''' Repository for user data access operations.
    ''' </summary>
    Public Class UserRepository

        ''' <summary>
        ''' Gets a user by username.
        ''' </summary>
        ''' <param name="username">The username to search for.</param>
        ''' <returns>The user if found, Nothing otherwise.</returns>
        Public Function GetByUsername(username As String) As User
            If String.IsNullOrEmpty(username) Then
                Return Nothing
            End If

            Using conn As NpgsqlConnection = DatabaseManager.GetConnection()
                conn.Open()

                Const sql As String = "SELECT user_id, dni, username, password_hash, role, full_name, email, is_active " &
                                       "FROM users WHERE username = @username"

                Using cmd As New NpgsqlCommand(sql, conn)
                    cmd.Parameters.AddWithValue("@username", username)

                    Using reader As NpgsqlDataReader = cmd.ExecuteReader()
                        If reader.Read() Then
                            Return MapReaderToUser(reader)
                        End If
                    End Using
                End Using
            End Using

            Return Nothing
        End Function

        ''' <summary>
        ''' Gets a user by ID.
        ''' </summary>
        ''' <param name="userId">The user ID to search for.</param>
        ''' <returns>The user if found, Nothing otherwise.</returns>
        Public Function GetById(userId As Integer) As User
            Using conn As NpgsqlConnection = DatabaseManager.GetConnection()
                conn.Open()

                Const sql As String = "SELECT user_id, dni, username, password_hash, role, full_name, email, is_active " &
                                       "FROM users WHERE user_id = @userId"

                Using cmd As New NpgsqlCommand(sql, conn)
                    cmd.Parameters.AddWithValue("@userId", userId)

                    Using reader As NpgsqlDataReader = cmd.ExecuteReader()
                        If reader.Read() Then
                            Return MapReaderToUser(reader)
                        End If
                    End Using
                End Using
            End Using

            Return Nothing
        End Function

        ''' <summary>
        ''' Maps a data reader row to a User object.
        ''' </summary>
        Private Function MapReaderToUser(reader As NpgsqlDataReader) As User
            Dim user As New User()
            user.UserId = reader.GetInt32(reader.GetOrdinal("user_id"))
            user.Dni = reader.GetString(reader.GetOrdinal("dni"))
            user.Username = reader.GetString(reader.GetOrdinal("username"))
            user.PasswordHash = reader.GetString(reader.GetOrdinal("password_hash"))
            user.Role = ParseRole(reader.GetString(reader.GetOrdinal("role")))
            user.FullName = reader.GetString(reader.GetOrdinal("full_name"))
            user.Email = If(reader.IsDBNull(reader.GetOrdinal("email")), Nothing, reader.GetString(reader.GetOrdinal("email")))
            user.IsActive = reader.GetBoolean(reader.GetOrdinal("is_active"))
            Return user
        End Function

        ''' <summary>
        ''' Parses a role string to UserRole enum.
        ''' </summary>
        Private Function ParseRole(roleString As String) As UserRole
            Select Case roleString.ToUpperInvariant()
                Case "DEPARTMENTHEAD", "DEPARTMENT_HEAD"
                    Return UserRole.DepartmentHead
                Case "TEACHER"
                    Return UserRole.Teacher
                Case "GROUPTUTOR", "GROUP_TUTOR"
                    Return UserRole.GroupTutor
                Case Else
                    Return UserRole.Teacher
            End Select
        End Function

    End Class

End Namespace
