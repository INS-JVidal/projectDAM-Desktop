Public Class Form1

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
