Imports System.Security.Cryptography
Imports System.Text

Namespace Utils

    ''' <summary>
    ''' Provides SHA-256 password hashing utilities.
    ''' </summary>
    Public Class PasswordHasher

        ''' <summary>
        ''' Hashes a password using SHA-256.
        ''' </summary>
        ''' <param name="password">The plain text password to hash.</param>
        ''' <returns>The SHA-256 hash of the password as a lowercase hexadecimal string.</returns>
        Public Shared Function HashPassword(password As String) As String
            If String.IsNullOrEmpty(password) Then
                Throw New ArgumentNullException(NameOf(password), "Password cannot be null or empty.")
            End If

            Using sha256 As SHA256 = SHA256.Create()
                Dim bytes As Byte() = Encoding.UTF8.GetBytes(password)
                Dim hashBytes As Byte() = sha256.ComputeHash(bytes)
                Return BitConverter.ToString(hashBytes).Replace("-", "").ToLowerInvariant()
            End Using
        End Function

        ''' <summary>
        ''' Verifies a password against a stored hash.
        ''' </summary>
        ''' <param name="password">The plain text password to verify.</param>
        ''' <param name="storedHash">The stored SHA-256 hash to compare against.</param>
        ''' <returns>True if the password matches the hash, false otherwise.</returns>
        Public Shared Function VerifyPassword(password As String, storedHash As String) As Boolean
            If String.IsNullOrEmpty(password) Then
                Return False
            End If

            If String.IsNullOrEmpty(storedHash) Then
                Return False
            End If

            Dim computedHash As String = HashPassword(password)
            Return String.Equals(computedHash, storedHash, StringComparison.OrdinalIgnoreCase)
        End Function

    End Class

End Namespace
