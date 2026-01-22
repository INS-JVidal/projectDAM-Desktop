Imports Evalis_Desktop.Services

Public Class Form1

    Private Const SESSION_CHECK_INTERVAL_MS As Integer = 60000 ' 60 seconds

    ''' <summary>
    ''' Handles the Form Load event.
    ''' Updates the window title with user information and starts the session timer.
    ''' </summary>
    Private Sub Form1_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        UpdateWindowTitle()
        StartSessionTimer()
    End Sub

    ''' <summary>
    ''' Updates the window title with the current user's name and role.
    ''' </summary>
    Private Sub UpdateWindowTitle()
        If AuthenticationService.IsAuthenticated AndAlso AuthenticationService.CurrentUser IsNot Nothing Then
            Dim user = AuthenticationService.CurrentUser
            Me.Text = $"EvAlis - {user.FullName} ({user.RoleDisplayName})"
        Else
            Me.Text = "EvAlis"
        End If
    End Sub

    ''' <summary>
    ''' Starts the session timeout timer.
    ''' </summary>
    Private Sub StartSessionTimer()
        SessionTimer.Interval = SESSION_CHECK_INTERVAL_MS
        SessionTimer.Enabled = True
        SessionTimer.Start()
    End Sub

    ''' <summary>
    ''' Handles the session timer tick event.
    ''' Checks for session timeout and refreshes the session if still active.
    ''' </summary>
    Private Sub SessionTimer_Tick(sender As Object, e As EventArgs) Handles SessionTimer.Tick
        If AuthenticationService.CheckSessionTimeout() Then
            SessionTimer.Stop()
            MessageBox.Show(
                "Your session has expired due to inactivity. The application will restart.",
                "Session Expired",
                MessageBoxButtons.OK,
                MessageBoxIcon.Warning
            )
            RestartApplication()
        Else
            ' Refresh the session to update last activity
            AuthenticationService.RefreshSession()
        End If
    End Sub

    ''' <summary>
    ''' Handles the Logout menu item click event.
    ''' </summary>
    Private Sub LogoutToolStripMenuItem_Click(sender As Object, e As EventArgs) Handles LogoutToolStripMenuItem.Click
        Dim result As DialogResult = MessageBox.Show(
            "Are you sure you want to logout?",
            "Confirm Logout",
            MessageBoxButtons.YesNo,
            MessageBoxIcon.Question
        )

        If result = DialogResult.Yes Then
            SessionTimer.Stop()
            AuthenticationService.Logout()
            RestartApplication()
        End If
    End Sub

    ''' <summary>
    ''' Restarts the application to show the login form again.
    ''' </summary>
    Private Sub RestartApplication()
        Application.Restart()
        Environment.Exit(0)
    End Sub

    ''' <summary>
    ''' Handles the Click event for the About menu item.
    ''' Displays application information in a message box.
    ''' </summary>
    Private Sub AboutToolStripMenuItem_Click(sender As Object, e As EventArgs) Handles AboutToolStripMenuItem.Click
        ' Build the About message
        Dim aboutMessage As String = String.Format(
            "EvAlis - Version 1.0.0" & Environment.NewLine & Environment.NewLine &
            "Institution: Institut Caparrella" & Environment.NewLine &
            "Purpose: Educational Evaluation Platform" & Environment.NewLine & Environment.NewLine &
            "Desktop administrative interface for managing evaluations, grades, and academic records." & Environment.NewLine & Environment.NewLine &
            "Developed for DAM2 - Desktop Development Module" & Environment.NewLine &
            "Academic Year 2025-2026" & Environment.NewLine &
            "Generalitat de Catalunya"
        )

        ' Display the About dialog
        MessageBox.Show(
            aboutMessage,
            "About EvAlis",
            MessageBoxButtons.OK,
            MessageBoxIcon.Information
        )
    End Sub

    ''' <summary>
    ''' Handles the Click event for the Exit menu item.
    ''' Closes the application with confirmation.
    ''' </summary>
    Private Sub ExitToolStripMenuItem_Click(sender As Object, e As EventArgs) Handles ExitToolStripMenuItem.Click
        Dim result As DialogResult = MessageBox.Show(
            "Are you sure you want to exit EvAlis?",
            "Confirm Exit",
            MessageBoxButtons.YesNo,
            MessageBoxIcon.Question
        )

        If result = DialogResult.Yes Then
            Me.Close()
        End If
    End Sub

    ''' <summary>
    ''' Placeholder handlers for future implementation
    ''' </summary>
    Private Sub NewToolStripMenuItem_Click(sender As Object, e As EventArgs) Handles NewToolStripMenuItem.Click
        MessageBox.Show("New functionality will be implemented in future phases.", "Not Yet Implemented", MessageBoxButtons.OK, MessageBoxIcon.Information)
    End Sub

    Private Sub OpenToolStripMenuItem_Click(sender As Object, e As EventArgs) Handles OpenToolStripMenuItem.Click
        MessageBox.Show("Open functionality will be implemented in future phases.", "Not Yet Implemented", MessageBoxButtons.OK, MessageBoxIcon.Information)
    End Sub

    Private Sub SaveToolStripMenuItem_Click(sender As Object, e As EventArgs) Handles SaveToolStripMenuItem.Click
        MessageBox.Show("Save functionality will be implemented in future phases.", "Not Yet Implemented", MessageBoxButtons.OK, MessageBoxIcon.Information)
    End Sub

    Private Sub UserGuideToolStripMenuItem_Click(sender As Object, e As EventArgs) Handles UserGuideToolStripMenuItem.Click
        MessageBox.Show("User Guide will be available in future phases.", "Not Yet Implemented", MessageBoxButtons.OK, MessageBoxIcon.Information)
    End Sub

End Class
