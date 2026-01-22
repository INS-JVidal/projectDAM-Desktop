Imports Evalis_Desktop.Services
Imports Evalis_Desktop.Utils

Public Class LoginForm

    ''' <summary>
    ''' Handles the form load event.
    ''' </summary>
    Private Sub LoginForm_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        ' Clear any previous entries
        TextBoxUsername.Clear()
        TextBoxPassword.Clear()
        HideError()

        ' Set focus to username field
        TextBoxUsername.Focus()
    End Sub

    ''' <summary>
    ''' Handles the Login button click event.
    ''' </summary>
    Private Sub ButtonLogin_Click(sender As Object, e As EventArgs) Handles ButtonLogin.Click
        PerformLogin()
    End Sub

    ''' <summary>
    ''' Handles the Cancel button click event.
    ''' </summary>
    Private Sub ButtonCancel_Click(sender As Object, e As EventArgs) Handles ButtonCancel.Click
        Me.DialogResult = DialogResult.Cancel
        Me.Close()
    End Sub

    ''' <summary>
    ''' Performs the login operation.
    ''' </summary>
    Private Sub PerformLogin()
        Dim username As String = TextBoxUsername.Text.Trim()
        Dim password As String = TextBoxPassword.Text

        ' Validate input
        If String.IsNullOrWhiteSpace(username) Then
            ShowError("Please enter your username.")
            TextBoxUsername.Focus()
            Return
        End If

        If String.IsNullOrWhiteSpace(password) Then
            ShowError("Please enter your password.")
            TextBoxPassword.Focus()
            Return
        End If

        ' Disable form during authentication
        SetFormEnabled(False)
        HideError()

        Try
            ' Attempt authentication
            Dim result As AuthenticationResult = AuthenticationService.Authenticate(username, password)

            If result.IsSuccess Then
                Me.DialogResult = DialogResult.OK
                Me.Close()
            Else
                ShowError(result.ErrorMessage)
                TextBoxPassword.Clear()
                TextBoxPassword.Focus()
            End If
        Catch ex As Exception
            ShowError("An error occurred during login. Please try again.")
            Logger.Instance.Error("LoginForm", "Unexpected error during login button click", ex)
        Finally
            SetFormEnabled(True)
        End Try
    End Sub

    ''' <summary>
    ''' Shows an error message.
    ''' </summary>
    Private Sub ShowError(message As String)
        LabelError.Text = message
        LabelError.Visible = True
    End Sub

    ''' <summary>
    ''' Hides the error message.
    ''' </summary>
    Private Sub HideError()
        LabelError.Text = String.Empty
        LabelError.Visible = False
    End Sub

    ''' <summary>
    ''' Enables or disables the form controls.
    ''' </summary>
    Private Sub SetFormEnabled(enabled As Boolean)
        TextBoxUsername.Enabled = enabled
        TextBoxPassword.Enabled = enabled
        ButtonLogin.Enabled = enabled
        ButtonCancel.Enabled = enabled
        Me.Cursor = If(enabled, Cursors.Default, Cursors.WaitCursor)
    End Sub

    ''' <summary>
    ''' Handles the KeyDown event to allow Enter key to submit.
    ''' </summary>
    Private Sub TextBoxPassword_KeyDown(sender As Object, e As KeyEventArgs) Handles TextBoxPassword.KeyDown
        If e.KeyCode = Keys.Enter Then
            PerformLogin()
            e.Handled = True
            e.SuppressKeyPress = True
        End If
    End Sub

    ''' <summary>
    ''' Handles the KeyDown event to allow Enter key to move to password.
    ''' </summary>
    Private Sub TextBoxUsername_KeyDown(sender As Object, e As KeyEventArgs) Handles TextBoxUsername.KeyDown
        If e.KeyCode = Keys.Enter Then
            TextBoxPassword.Focus()
            e.Handled = True
            e.SuppressKeyPress = True
        End If
    End Sub

End Class
