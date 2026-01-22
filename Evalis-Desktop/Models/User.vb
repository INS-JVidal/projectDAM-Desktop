Namespace Models

    ''' <summary>
    ''' Represents a user role in the EvAlis system.
    ''' </summary>
    Public Enum UserRole
        DepartmentHead = 1
        Teacher = 2
        GroupTutor = 3
    End Enum

    ''' <summary>
    ''' Represents a user entity in the EvAlis system.
    ''' </summary>
    Public Class User

        ''' <summary>
        ''' Unique identifier for the user.
        ''' </summary>
        Public Property UserId As Integer

        ''' <summary>
        ''' User's national identification number (DNI).
        ''' </summary>
        Public Property Dni As String

        ''' <summary>
        ''' Username for login.
        ''' </summary>
        Public Property Username As String

        ''' <summary>
        ''' SHA-256 hashed password.
        ''' </summary>
        Public Property PasswordHash As String

        ''' <summary>
        ''' User's role in the system.
        ''' </summary>
        Public Property Role As UserRole

        ''' <summary>
        ''' User's full name.
        ''' </summary>
        Public Property FullName As String

        ''' <summary>
        ''' User's email address.
        ''' </summary>
        Public Property Email As String

        ''' <summary>
        ''' Indicates if the user account is active.
        ''' </summary>
        Public Property IsActive As Boolean

        ''' <summary>
        ''' Default constructor.
        ''' </summary>
        Public Sub New()
            IsActive = True
        End Sub

        ''' <summary>
        ''' Gets the role display name.
        ''' </summary>
        Public ReadOnly Property RoleDisplayName As String
            Get
                Select Case Role
                    Case UserRole.DepartmentHead
                        Return "Department Head"
                    Case UserRole.Teacher
                        Return "Teacher"
                    Case UserRole.GroupTutor
                        Return "Group Tutor"
                    Case Else
                        Return "Unknown"
                End Select
            End Get
        End Property

    End Class

End Namespace
